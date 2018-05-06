#include "honors4.h"

int main(int argc, char *argv[])
{

    int i,j;
    int size=atoi(argv[3]); // number of men or women
    int **men=malloc(sizeof *men *size); // men prefernce matrix
    int **women=malloc(sizeof *women *size); // women preference matrix
    int *solution=malloc(sizeof *solution *size); // solution or marriage matrix
    if(men && women) // checking if the mallocs worked
    {
        for(i=0;i<size;i++)
        {
            men[i]=malloc(sizeof *men[i] *size);
            women[i]=malloc(sizeof *women[i] *size);
        }
    }
    readPrefFiles(argv[1],argv[2],size,men,women); // reading in the men and women preferences
    printf("Male Preference Matrix:\n");
    for(i=0;i<size;i++)
    {
        for(j=0;j<size;j++)
        {
            printf("%d ",men[i][j]);
        }
        printf("\n");
    }
    printf("\n\n");
    printf("Female Preference Matrix:\n");
    for(i=0;i<size;i++)
    {
        for(j=0;j<size;j++)
        {
            printf("%d ",women[i][j]);
        }
        printf("\n");
    }

    maleOptimalSolution(men,women,solution,size);
    printf("\n\nSolution Matrix:\n");
    for(i=0;i<size;i++) // printing out the solution
    {
        printf("%d ",solution[i]);
    }
    printf("\n");

	free(solution);
	solution=NULL;
	solution=malloc(sizeof *solution *size);
    maleOptimalSolution(women,men,solution,size);
    printf("\n\nSolution Matrix:\n");
    for(i=0;i<size;i++) // printing out the solution
    {
        printf("%d ",solution[i]);
    }
    printf("\n");

}
