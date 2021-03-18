## ECE549 / CS543 Computer Vision, Spring 2021, Assignment 0

### Instructions

1.  Assignment is due at **11:59:59 PM on Wednesday Feb 10 2021**.

2.  See [policies](http://saurabhg.web.illinois.edu/teaching/ece549/sp2021/policies.html)
    on [class website](http://saurabhg.web.illinois.edu/teaching/ece549/sp2021/).

3.  Submission instructions:

    1.  A single `.pdf` report that contains your work for Q1, Q2 and
        Q3. For Q1 and Q2 you can either type out your responses in LaTeX, or
        any other word processing software.  You can also hand write them on a
        tablet, or scan in hand-written answers. If you hand-write, please make
        sure they are neat and legible. If you are scanning, make sure that the
        scans are legible. Lastly, convert your work into a `PDF`. 

        For Q3 your response should be electronic (no handwritten responses
        allowed). You should respond to the questions 3.1, 3.2 and 3.3
        individually and include images as necessary. Your response to Q3 in
        the PDF report should be self-contained. It should include all the
        output you want us to look at. You will not receive credit for any
        results you have obtained, but failed to include directly in the PDF
        report file. 

        PDF file should be submitted to
        [Gradescope](https://www.gradescope.com) under `MP0`. Course code is
        **3YR7GY**. Please tag the reponses in your PDF with the Gradescope
        questions outline  as described in
        [Submitting an Assignment](https://youtu.be/u-pK4GzpId0). 

    2.  You also need to submit code for Q3 in the form of a single
        `.zip` file that includes all your code, all in the same
        directory. You can submit Python code in either `.py` or
        `.ipynb` format. Code should also be submitted to
        [Gradescope](https://www.gradescope.com) under `MP0-Code`. 
        *Not submitting your code will lead to a loss of
        100% of the points on Q3.*

    3.  We reserve the right to take off points for not following
        submission instructions. In particular, please tag the reponses
        in your PDF with the Gradescope questions outline as described
        in [Submitting an Assignment](https://youtu.be/u-pK4GzpId0). 

4.  Lastly, be careful not to work of a public fork of this repo. Make a
    private clone to work on your assignment. You are responsible for
    preventing other students from copying your work. Please also see point 2
    above.


### Problems


1.  **Calculus Review [10 pts].**

    The $`\operatorname{softmax}`$ function is a commonly-used operator which
    turns a vector into a valid probability distribution, i.e. non-negative
    and sums to 1.

    For vector $`\mathbf{z}= (z_1, z_2, \ldots, z_k) \in \mathbb{R}^k`$, the
    output $`\mathbf{y}= \operatorname{softmax}({\mathbf{z}}) \in \mathbb{R}^k`$,
    and its $`i`$-th element is defined as
    ```math
    y_i = \operatorname{softmax}({\mathbf{z}})_i = \frac{ \exp(z_i) }{ \sum_{j=1}^k \exp(z_j)}
    ```
    
    Answer the following questions about the $`\operatorname{softmax}`$ function.
    Show the calculation steps (as applicable) to get full credit.

    1.  **Shift Invariance [3 pts].** Verify that
        $`\operatorname{softmax}({\mathbf{z}})`$ is invariant to constant
        shifting on $`{\mathbf{z}}`$, i.e.
        $`\operatorname{softmax}({\mathbf{z}}) = \operatorname{softmax}({\mathbf{z}}- C\mathbf{1})`$
        where $`C \in \mathbb{R}`$ and $`\mathbf{1}`$ is the all-one vector. The
        $`\operatorname{softmax}({\mathbf{z}}- \max_j z_j)`$
        [trick](https://timvieira.github.io/blog/post/2014/02/11/exp-normalize-trick/)
        is used in deep learning packages to avoid numerical overflow.

    2.  **Derivative [3 pts].** Let
        $`y_i = \operatorname{softmax}({\mathbf{z}})_i, 1\le i\le k`$.
        Compute the derivative $`\frac{\partial y_i}{\partial z_j}`$ for any
        $`i,j`$. Your result should be as simple as possible, and may contain
        elements of $`{\mathbf{y}}`$ and/or $`{\mathbf{z}}`$.

    3.  **Chain Rule [4 pts].** Consider $`{\mathbf{z}}`$ to be the output of a
        linear transformation $`{\mathbf{z}}= W^\top {\mathbf{x}} + {\mathbf{u}}`$, where
        vector $`{\mathbf{x}}\in \mathbb{R}^d`$, matrix
        $`W \in \mathbb{R}^{d \times k}`$, and vector $`{\mathbf{u}} \in \mathbb{R}^k`$. Denote
        $`\{ {\mathbf{w}}_1, {\mathbf{w}}_2, \ldots, {\mathbf{w}}_k \}`$ as
        the columns of $`W`$. Let
        $`{\mathbf{y}}= \operatorname{softmax}({\mathbf{z}})`$. Compute
        $`\frac{\partial y_i}{\partial {\mathbf{x}}}`$, 
        $`\frac{\partial y_i}{\partial {\mathbf{w}}_j}`$, and
        $`\frac{\partial y_i}{\partial {\mathbf{u}}}`$. (Hint: You may
        reuse (1.2) and apply the chain rule. Vector derivatives:
        $`\frac{\partial (\mathbf{a} \cdot \mathbf{b}) }{\partial \mathbf{a} } = \mathbf{b}`$,
        $`\frac{\partial (\mathbf{a} \cdot \mathbf{b}) }{\partial \mathbf{b} } = \mathbf{a}`$
        .)

2.  **Linear Algebra Review [10 pts].** Answer the following questions about
    matrices. Show the calculation steps (as applicable) to get full credit.

    1.  **Matrix Multiplication [2 pts].** Let $`V = 
            \begin{bmatrix}
                -\frac1{\sqrt{2}} & -\frac1{\sqrt{2}}  \\
                 \frac1{\sqrt 2}  & -\frac1{\sqrt 2} 
            \end{bmatrix}`$. Compute
        $` V \begin{bmatrix} 1 \\ 0 \end{bmatrix}`$,
        $` V \begin{bmatrix} 0 \\ 1 \end{bmatrix}`$. What does matrix
        multiplication $`Vx`$ do to $`x`$?

    2.  **Matrix Transpose [2 pts].**  Verify that $`V^{-1} = V^\top`$. What does
        $`V^\top x`$ do?

    3.  **Diagonal Matrix [2 pts].**  Let $`\Sigma = 
            \begin{bmatrix}
                \sqrt{8} & 0 \\
                0 & 2
            \end{bmatrix}`$. Compute $`\Sigma V^\top x`$ where
        $`x = \begin{bmatrix} \frac1{\sqrt{2}} \\ 0 \end{bmatrix}, 
            \begin{bmatrix} 0 \\ \frac1{\sqrt{2}} \end{bmatrix}, 
            \begin{bmatrix} -\frac1{\sqrt{2}} \\ 0 \end{bmatrix}, 
            \begin{bmatrix} 0 \\ -\frac1{\sqrt{2}} \end{bmatrix}`$ respectively.
        These are 4 corners of a square. What is the shape of the result
        points?

    4.  **Matrix Multiplication II [2 pts].**  Let $`U = 
            \begin{bmatrix}
                -\frac{\sqrt 3}2 & \frac12 \\
                -\frac12 & -\frac{\sqrt 3}2
            \end{bmatrix}`$. What does $`Ux`$ do? 
            ([Rotation matrix wiki](https://en.wikipedia.org/wiki/Rotation_matrix))

    5.  **Geometric Interpretation [2 pts].**  Compute $`A = U\Sigma V^T`$. From the above
        questions, we can see a geometric interpretation of $`Ax`$: (1) $`V^T`$
        first rotates point $`x`$, (2) $`\Sigma`$ rescales it along the
        coordinate axes, (3) then $`U`$ rotates it again. Now consider a
        general squared matrix $`B \in \mathbb{R}^{n\times n}`$. How would you obtain
        a similar geometric interpretation for $`Bx`$?

3.  **Un-shredding Images [30 pts].**
    We accidentally shredded some images! In this problem, we will recover the
    original images from the corresponding shreds. Along the way we will learn how
    to deal with and process images in Python. Example input / output is shown
    below.
    
    <div align="center">
    <img src="shredded.png" width="75%">
    <img src="output.png" width="75%">
    </div>
    
    1.  **Combine [5 pts].** We will start simple, and work with images where the
        shredder simply divided the image into vertical strips. These are prefixed
        with `simple_` in the [shredded-images](shredded-images) folder. Each folder
        contains the shreds (as individual files) for that particular image.
    
        Our first task is to take these strips and concatenate them (in any order)
        to produce a complete image. Without proper ordering of the strips, this
        image won't quite look correct, but that's ok for now. We will tackle that
        in the next part. For now, save this weird composite image. **Include the
        generated image into your report.**
    
    2.  **Re-order [10 pts].** As you noticed, without correctly ordering the
        strips, the images didn't quite look correct. Our goal now is to identify the
        correct ordering for these strips. We will adopt a very simple greedy
        algorithm. For each pair of strips, we will compute how well does strip 1 go
        immediately left of strip 2. We will do this my measuring the similarity
        between the last column of pixels in strip 1 and the first column of pixels in
        strip 2. You can measure similarity using (negative of) the *sum of squared
        differences* which is simply the L2 norm of the pixel difference.
        
        Once you have computed the similarity between all pairs of strips, you can
        follow a greedy algorithm to composite the image together. Start with a
        strip and place the strip that is most compatible with it on the left and
        the right side, and so on. Compose the strips together into an image using
        this simple greedy algorithm.
    
        **Save the generated composite images for all the `simple_` shreds from the
        `shredded-images` folder, and include them in your report. Also include a
        brief description of your implemented solution, focusing especially on the
        more non-trivial or interesting parts of the solution.**
        
    3.  **Align and Re-order [15 pts].** Next, we will tackle the case where our
        shredder also cut out the edges of some of the strips, so that they are no
        longer aligned vertically. These are prefixed with `hard_`. We will now
        modify the strip similarity function from the previous part to compensate for
        this vertical misalignment.
    
        We will vertically slide one strip relative to the other, in the range of 20% 
        of the vertical dimension to find the best alignment, and compute
        similarity between the overlapping parts for different slide amounts. We
        will use the *maximum* similarity over these different slide amounts, as the
        similarity between the two strips. Note that you may need to experiment with
        similarity functions other than the sum of squared distances. One common
        alternative is *zero mean normalized cross correlation*, which is simply the
        dot product between the two pixel vectors after they have been normalized to
        have zero mean and unit norm.
    
        Implement this strategy for measuring the similarity between the strips. Use
        this along with the greedy re-ordering strategy in the previous part, to
        reconstruct this harder set of shreds. You will also have to keep track of
        the slide amounts that led to the best match. You will need those when you
        stitch the shreds together.
    
        **Save the generated composite images for all the `hard_` shreds, and
        include them in your report. As before, include a brief description of your
        implemented solution, focusing especially on the more non-trivial or
        interesting parts of the solution.  What design choices did you make, and
        how did they affect the quality of the result and the speed of computation?
        What are some artifacts and/or limitations of your implementation, and what
        are possible reasons for them?**
