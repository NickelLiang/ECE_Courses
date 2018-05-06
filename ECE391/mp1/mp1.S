
.data					# section declaration

        # Useful offset constants for accessing members of a
        # struct mp1_blink_struct structure
        LOCATION   = 0
        ON_CHAR    = 2
        OFF_CHAR   = 3
        ON_LENGTH  = 4
        OFF_LENGTH = 6
        COUNTDOWN  = 8
        STATUS     = 10
        NEXT       = 12

        STRUCT_SIZE = 16

# Pointer to head of list (initialized to NULL)
mp1_list_head:
        .long   0

.text					# section declaration

# Export the function symbol names

.global mp1_rtc_tasklet
.global mp1_ioctl

# void mp1_poke(void);
#
# Interface: Register-based arguments (not C-style)
#    Inputs: %cl  - The byte you wish to write
#            %eax - Offset from the start of video memory that you wish
#                   to write to
#   Outputs: Text-mode video screen is written to at location %eax with
#            the byte in %cl
# Registers: Clobbers EDX
mp1_poke:
	movl    vmem_base_addr(,1),%edx
	movb    %cl,(%edx,%eax,1)
	ret

# ======================================================================
# int mp1_rtc_tasklet(void);
# Interface: C-style
#    Inputs:
#   Outputs:
# Registers: All registers
#
mp1_rtc_tasklet:
    # Callee Setup
    pushl   %ebp                        #
    movl    %esp, %ebp                  #
    # Callee Save
    pushl   %ebx                        #
    pushl   %esi                        #
    pushl   %edi                        #
    # Load HEAD Addr
    movl    mp1_list_head, %ebx         # ebx <- mp1_list_head
# Walk Through the List
mp1_tasklet_loop:
    cmpl    $0, %ebx                    # Compare struct pointer with 0
    je      mp1_tasklet_done            # Point to NULL, end of list
    # Decrement the COUNTDOWN
    decw    COUNTDOWN(%ebx)             # COUNTDOWN --
    # Check COUNTDOWN
    cmpw    $0, COUNTDOWN(%ebx)         # Compare COUNTDOWN with 0
    jne     mp1_tasklet_loop_done       # COUNTDOWN != 0, no operation needed
    # Check STATUS
    cmpw    $0, STATUS(%ebx)            # Compare STATUS with 0
    je      mp1_tasklet_loop_zero       # STATUS = 0, go to STATUS 0 op
    jmp     mp1_tasklet_loop_one        # STATUS = 1, go to STATUS 1 op
mp1_tasklet_loop_zero:
    # Set COUNTDOWN Field
    movw    ON_LENGTH(%ebx), %cx        # cx <- ON_LENGTH
    movw    %cx, COUNTDOWN(%ebx)        # COUNTDOWN <- cx
    # Set STATUS Field
    movw    $1, STATUS(%ebx)            # M[ebx+10] <- 1 (STATUS = 1)
    # Prepare for Poke
    movb    ON_CHAR(%ebx), %cl          # cl <- M[ebx+2] (ON_CHAR)
    jmp     mp1_tasklet_loop_poke       # Poke!
mp1_tasklet_loop_one:
    # Set COUNTDOWN Field
    movw    OFF_LENGTH(%ebx), %cx       # cx <- OFF_LENGTH
    movw    %cx, COUNTDOWN(%ebx)        # COUNTDOWN <- cx
    # Set STATUS Field
    movw    $0, STATUS(%ebx)            # M[ebx+10] <- 1 (STATUS = 1)
    # Prepare for Poke
    movb    OFF_CHAR(%ebx), %cl         # cl <- M[ebx+2] (ON_CHAR)
    jmp     mp1_tasklet_loop_poke       # Poke!
mp1_tasklet_loop_poke:
# Call mp1_poke
    # Caller Save
    pushl   %eax                        #
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    movw    (%ebx), %ax                 # ax <- M[ebx] (LOCATION)
    movzwl  %ax, %eax                   # eax <- ax, zero extended
    addl    %eax, %eax                  # eax <- 2*eax, find correct memory location
    call    mp1_poke                    # unsigned long mp1 copy from user (void *to, const void *from, unsigned long n)
    # Caller Teardown
    popl    %edx                        #
    popl    %ecx                        #
    popl    %eax                        #
    jmp     mp1_tasklet_loop_done       #
mp1_tasklet_loop_done:
    # Update Pointer
    movl    NEXT(%ebx), %ebx            # ebx <- NEXT
    jmp     mp1_tasklet_loop            # Check next node
mp1_tasklet_done:
    # Callee Teardown
    popl    %edi                        #
    popl    %esi                        #
    popl    %ebx                        #
    leave                               #
	ret                                 #

# ======================================================================
# int mp1_ioctl(unsigned long arg, unsigned long cmd);
# Interface: C-style
#    Inputs: arg - Argument for each operation
#            cmd - Operation to perform
#   Outputs: 0   - Success
#            -1  - Quit with error
# Registers: All registers
#
mp1_ioctl:
    # Callee Setup
    pushl   %ebp                        #
    movl    %esp, %ebp                  #
    # Callee Save
    pushl   %ebx                        #
    pushl   %esi                        #
    pushl   %edi                        #
    # Jump to proper ioctl function
    movl    12(%ebp), %eax              # Load cmd into caller saved eax
    cmpl    $3, %eax                    # Compare command number with 3
    ja      mp1_ioctl_error             # unsigned eax >  3, invalid command
    jmp     *mp1_ioctl_jumptable(,%eax,4)   # unsigned eax <= 3, jump to proper function
# ----------------------------------------------------------------------
mp1_ioctl_add:
# Local Variable
    subl    $4, %esp                    # Make room for malloc return pointer
# Check Argument Validity
    cmpl    $0, 8(%ebp)                 # Compare input 'arg' with 0
    je      mp1_ioctl_error             # arg = 0, invalid argument
# Dynamically allocate memory to store a copy of the structure
    # Caller Save
    pushl   %eax                        #
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    pushl   $STRUCT_SIZE                # Push parameter 'size' (size of structure)
    call    mp1_malloc                  # void* mp1_malloc(unsigned long size)
    # Caller Teardown
    leal    4(%esp), %esp               # Pop 1 parameter
    movl    %eax, -16(%ebp)             # ptr* <- eax, pointer to new malloc
    popl    %edx                        #
    popl    %ecx                        #
    popl    %eax                        #
    # Memory allocation error check
    cmpl    $-1, -16(%ebp)              # Compare return value with -1
    je      mp1_ioctl_error             # return = -1, malloc error
# Copy the structure from user
    # Caller Save
    pushl   %eax                        #
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    pushl   $STRUCT_SIZE                # Push parameter 'n' (size of structure)
    pushl   8(%ebp)                     # Push parameter 'from' ('arg' of ioctl)
    pushl   -16(%ebp)                   # Push parameter 'to' (malloc returned *ptr)
    call    mp1_copy_from_user          # unsigned long mp1 copy from user (void *to, const void *from, unsigned long n)
    # Caller Teardown
    leal    12(%esp), %esp              # Pop 3 parameters
    movl    %eax, %ebx                  # ebx <- eax, ebx: number of bytes failed to copy
    popl    %edx                        #
    popl    %ecx                        #
    popl    %eax                        #
    # Copy Check
    cmpl    $0, %ebx                    # Compare return value with 0
    jne     mp1_ioctl_error_free        # return != 0, copy error, free malloced memory
# Set Fields
    # Load Structure Starting Addr
    movl    -16(%ebp), %ebx
    # Location Check
    movw    (%ebx), %cx                 # cx <- M[ebx] (LOCATION)
    movzwl  %cx, %ecx                   # zero extend cx
    cmpw    $25*80, %cx                 # Compare cx (LOCATION) with 25*80
    jae     mp1_ioctl_error_free        # location >= 2000, location error, free malloced memory
    # Set COUNTDOWN Field
    movw    ON_LENGTH(%ebx), %cx        # cx <- ON_LENGTH
    movw    %cx, COUNTDOWN(%ebx)        # COUNTDOWN <- cx
    # Set STATUS Field
    movw    $1, STATUS(%ebx)            # M[ebx+10] <- 1 (STATUS = 1)
    # Set NEXT Field
    movl    mp1_list_head, %esi         # esi <- mp1_list_head
    movl    %esi, NEXT(%ebx)            # NEXT <- esi
# Insert to the head of the list
    movl    %ebx, mp1_list_head         # mp1_list_head <- ebx
# Call mp1_poke
    # Caller Save
    pushl   %eax                        #
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    movb    ON_CHAR(%ebx), %cl          # cl <- M[ebx+2] (ON_CHAR)
    movw    (%ebx), %ax                 # ax <- M[ebx] (LOCATION)
    movzwl  %ax, %eax                   # eax <- ax, zero extended
    addl    %eax, %eax                  # eax <- 2*eax, find correct memory location
    call    mp1_poke                    # unsigned long mp1 copy from user (void *to, const void *from, unsigned long n)
    # Caller Teardown
    popl    %edx                        #
    popl    %ecx                        #
    popl    %eax                        #
# Destroy Local Variable
    addl    $4, %esp                    # Pop local var off stack
    jmp     mp1_ioctl_success           #
# ----------------------------------------------------------------------
mp1_ioctl_remove:
# Prepare Call
    movl    8(%ebp), %ecx               # Take argument
    movw    %cx, %dx                    # dx <- target location
    movl    mp1_list_head, %esi         # esi <- list head
# Call mp1_find_node
    # Caller Save
    # eax & edx is not saved since it was used for return (this helper only)
    pushl   %ecx                        #
    # Caller Setup
    pushw   %dx                         # location
    pushl   %esi                        # list head
    call    mp1_find_node               #
    # Caller Teardown
    leal    6(%esp), %esp               # Pop 2 parameters, one l & one w
    popl    %ecx                        #
    # Check Return
    cmpl    $-1, %eax                   # Check location validity base on return
    je      mp1_ioctl_error             #
    cmpl    mp1_list_head, %eax         # Check if we are removing head node
    je      mp1_ioctl_remove_head       #
# Delete Node
    movl    NEXT(%eax), %ecx            # ecx <- cur.next
    movl    %ecx, NEXT(%edx)            # pre.next <- ecx
    jmp     mp1_ioctl_remove_free       #
mp1_ioctl_remove_head:
    movl    NEXT(%eax), %ecx            # ecx <- cur.next
    movl    %ecx, mp1_list_head         # mp1_list_head <- ecx
mp1_ioctl_remove_free:
# Free Node
    # Caller Save
    pushl   %eax                        #
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    pushl   %eax                        # *cur
    call    mp1_free                    # void mp1_free(void *ptr)
    # Caller Teardown
    leal    4(%esp), %esp               # Pop 1 parameter
    popl    %edx                        #
    popl    %ecx                        #
    popl    %eax                        #
	jmp     mp1_ioctl_success           #
# ----------------------------------------------------------------------
mp1_ioctl_find:
# Check Argument Validity
    cmpl    $0, 8(%ebp)                 # Compare input 'arg' with 0
    je      mp1_ioctl_error             # arg = 0, invalid argument
# Read Location from Target Structure
    movl    8(%ebp), %edi               # Target Structure Base at edi
    movw    LOCATION(%edi), %dx         # dx <- target location
# Find Location from Source Structure
    movl    mp1_list_head, %esi         # Source Structure Base at esi
# Call mp1_find_node
    # Caller Save
    # eax is not saved since it was used for return (this helper only)
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    pushw   %dx                         # location
    pushl   %esi                        # list head
    call    mp1_find_node               #
    # Caller Teardown
    leal    6(%esp), %esp               # Pop 2 parameters, one l & one w
    popl    %edx                        #
    popl    %ecx                        #
    # Check Return
    cmpl    $-1, %eax                   # Check location validity base on return
    je      mp1_ioctl_error             #
# Copy Structure from Source to Target
    # Caller Save
    pushl   %eax                        #
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    pushl   $STRUCT_SIZE                # Push parameter 'n' (size of structure)
    pushl   %eax                        # Push parameter 'from'
    pushl   %edi                        # Push parameter 'to'
    call    mp1_copy_to_user            # (void *to, const void *from, unsigned long n)
    # Caller Teardown
    leal    12(%esp), %esp              # Pop 3 parameters
    movl    %eax, %ebx                  # ebx <- eax, ebx: number of bytes failed to copy
    popl    %edx                        #
    popl    %ecx                        #
    popl    %eax                        #
    # Copy Check
    cmpl    $0, %ebx                    # Compare return value with 0
    jne     mp1_ioctl_error             # return != 0, copy error
	jmp     mp1_ioctl_success           #
# ----------------------------------------------------------------------
mp1_ioctl_sync:
# Extract 2 Arguments
    movw    8(%ebp), %di                # di <- Second arg in lower 16 bits
    movw    10(%ebp), %si               # si <- First arg in upper 16 bits
    movl    mp1_list_head, %ebx         # Source Structure Base at esi
# Find First Address
    # Call mp1_find_node
    # Caller Save
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    pushw   %si                         # location
    pushl   %ebx                        # list head
    call    mp1_find_node               #
    # Caller Teardown
    leal    6(%esp), %esp               # Pop 2 parameters, one l & one w
    popl    %edx                        #
    popl    %ecx                        #
    # Check Return
    cmpl    $-1, %eax                   # Check location validity base on return
    je      mp1_ioctl_error             # Invalid location
    movl    %eax, %esi                  # esi <- First argument address
# Find Second Address
    # Call mp1_find_node
    # Caller Save
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    pushw   %di                         # location
    pushl   %ebx                        # list head
    call    mp1_find_node               #
    # Caller Teardown
    leal    6(%esp), %esp               # Pop 2 parameters, one l & one w
    popl    %edx                        #
    popl    %ecx                        #
    # Check Return
    cmpl    $-1, %eax                   # Check location validity base on return
    je      mp1_ioctl_error             # Invalid location
    movl    %eax, %edi                  # edi <- First argument address
# Copy Timing from First to Second
    # Copy ON_LENGTH
    movw    ON_LENGTH(%esi), %cx        # ecx <- ON_LENGTH of arg 1
    movw    %cx, ON_LENGTH(%edi)        # ON_LENGTH of arg 2 <- ecx
    # Copy OFF_LENGTH
    movw    OFF_LENGTH(%esi), %cx       # ecx <- OFF_LENGTH of arg 1
    movw    %cx, OFF_LENGTH(%edi)       # OFF_LENGTH of arg 2 <- ecx
    # Copy COUNTDOWN
    movw    COUNTDOWN(%esi), %cx        # ecx <- COUNTDOWN of arg 1
    movw    %cx, COUNTDOWN(%edi)        # COUNTDOWN of arg 2 <- ecx
    # Copy STATUS
    movw    STATUS(%esi), %cx           # ecx <- STATUS of arg 1
    movw    %cx, STATUS(%edi)           # STATUS of arg 2 <- ecx
# Check STATUS
    cmpw    $0, STATUS(%edi)            # Compare STATUS with 0
    je      mp1_ioctl_sync_zero         # STATUS = 0, go to STATUS 0 op
    jmp     mp1_ioctl_sync_one          # STATUS = 1, go to STATUS 1 op
mp1_ioctl_sync_zero:
    movb    OFF_CHAR(%edi), %cl         # cl <- M[ebx+2] (OFF_CHAR)
    jmp     mp1_ioctl_sync_poke         # Poke!
mp1_ioctl_sync_one:
    movb    ON_CHAR(%edi), %cl          # cl <- M[ebx+2] (ON_CHAR)
    jmp     mp1_ioctl_sync_poke         # Poke!
# Call Poke for Second Location
mp1_ioctl_sync_poke:
    # Caller Save
    pushl   %eax                        #
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    movw    LOCATION(%edi), %ax         # ax <- M[edi] (LOCATION)
    movzwl  %ax, %eax                   # eax <- ax, zero extended
    addl    %eax, %eax                  # eax <- 2*eax, find correct memory location
    call    mp1_poke                    # unsigned long mp1 copy from user (void *to, const void *from, unsigned long n)
    # Caller Teardown
    popl    %edx                        #
    popl    %ecx                        #
    popl    %eax                        #
	jmp     mp1_ioctl_success           #
# ----------------------------------------------------------------------
mp1_ioctl_success:
    movl    $0, %eax                    # eax <- 0, success indicator
    jmp     mp1_ioctl_done              #
mp1_ioctl_error_free:
    # Caller Save
    pushl   %eax                        #
    pushl   %ecx                        #
    pushl   %edx                        #
    # Caller Setup
    pushl   -16(%ebp)                   # Push parameter '*ptr' (malloc returned *ptr)
    call    mp1_free                    # void mp1_free(void *ptr)
    # Caller Teardown
    leal    4(%esp), %esp               # Pop 1 parameter
    popl    %edx                        #
    popl    %ecx                        #
    popl    %eax                        #
    jmp     mp1_ioctl_error             # exit with an error
mp1_ioctl_error:
    movl    $-1, %eax                   # eax <- -1, error indicator
    jmp     mp1_ioctl_done              # exit with an error
mp1_ioctl_done:
    # Callee Teardown
    popl    %edi                        #
    popl    %esi                        #
    popl    %ebx                        #
    leave                               #
    ret                                 #
mp1_ioctl_jumptable:
    .long mp1_ioctl_add, mp1_ioctl_remove, mp1_ioctl_find, mp1_ioctl_sync

# ======================================================================

# mp1_blink_struct* mp1_find_node(* ptr, location)
# Interface: C-style
#    Inputs: *ptr     - list head pointer
#            location - location to be find
#   Outputs: -1       - invalid location
#            *ptr     - pointer to start of the node 
# Registers: All registers
#
mp1_find_node:
    # Callee Setup
    pushl   %ebp                        #
    movl    %esp, %ebp                  #
    # Callee Save
    pushl   %ebx                        #
    pushl   %esi                        #
    pushl   %edi                        #
    # Get Arguments
    movl    8(%ebp), %esi               # esi <- list head
    movw    12(%ebp), %dx               # dx <- location
    # Location Check
    cmpw    $25*80, %dx                 # Compare dx (LOCATION) with 25*80
    jae     mp1_find_node_error         # location >= 2000, location error
mp1_find_node_loop:
    cmpl    $0, %esi                    # Compare struct pointer with 0
    je      mp1_find_node_error         # Point to NULL, end of list, No Location Found
    movw    LOCATION(%esi), %cx         # cx <- source location
    cmpw    %cx, %dx                    # Compare cx with dx
    je      mp1_find_node_found         # Found the location
    # Update Pointer
    movl    %esi, %ebx                  # ebx contain previous node base ptr
    movl    NEXT(%esi), %esi            # esi <- NEXT
    jmp     mp1_find_node_loop          # Check next node
mp1_find_node_error:
    movl    $-1, %eax                   # eax <- -1, error indicator
    jmp     mp1_find_node_done          # exit with an error
mp1_find_node_found:
    movl    %ebx, %edx                  # edx is a common return register
    movl    %esi, %eax                  # eax <- esi
    jmp     mp1_find_node_done          # return node addr
mp1_find_node_done:
    # Callee Teardown
    popl    %edi                        #
    popl    %esi                        #
    popl    %ebx                        #
    leave                               #
    ret                                 #

# ======================================================================

.end
