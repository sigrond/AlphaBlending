#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int blend(char* a,char* b,float c,char* d, int x, int y);

int main()
{
    FILE* file1;
    FILE* file2;
    long int size1, size2;
    char* m1;
    char* m2;
    char* result;
    float alpha=0.4;
    int x=0,y=0;//w pixelach
    file1=fopen("test1.bmp", "rb");
    file2=fopen("test2.bmp", "rb");
    fseek(file1,0,SEEK_END);
    fseek(file2,0,SEEK_END);
    size1=ftell(file1);
    size2=ftell(file2);
    rewind(file1);
    rewind(file2);
    m1=(char*)malloc(sizeof(char)*size1);
    m2=(char*)malloc(sizeof(char)*size2);
    //result=(char*)malloc(sizeof(char)*(size1>size2?size1:size2));
    result=(char*)malloc(sizeof(char)*size1);
    fread(m1,sizeof(char),size1,file1);
    fread(m2,sizeof(char),size2,file2);
    fclose(file1);
    fclose(file2);
    memcpy(result,m1,sizeof(char)*size1);
    blend(m1,m2,alpha,result,x,y);
    return 0;
}
