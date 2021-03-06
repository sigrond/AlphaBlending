#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include<X11/X.h>
#include<X11/Xlib.h>
#include<X11/keysym.h>
#include<X11/Xutil.h>
//#include<GL/gl.h>
//#include<GL/glx.h>
//#include<GL/glu.h>



int blend(char* a,char* b,float c,char* d, int x, int y);

#define KROK 10
long int size1, size2;
int x=0,y=0;//w pixelach
float alpha=0.4;

XImage *CreateTrueColorImage(Display *display, Visual *visual, unsigned char *image,
                             int width, int height)
{
    int i, j;
    unsigned char *image32=(unsigned char *)malloc(width*height*4);
    unsigned char *p=image32;
    int k=size1;//54;
    int padding=((width*24+31)/32)*4-width*3;
    //printf("padding: %d\n",padding);
    for(i=0; i<height; i++)
    {
        k-=width*3+padding;
        for(j=0; j<width; j++)
        {
            *p++= *(image+k++); // blue
            *p++= *(image+k++); // green
            *p++= *(image+k++); // red
            p++;
        }
        //k+=padding;
        k-=width*3;
    }
    return XCreateImage(display, visual, 24, ZPixmap, 0, image32, width, height, 32, 0);
}

void processEvent(Display *display, Window window, XImage *ximage,
                  int width, int height, int width2, int height2)
{
    XEvent ev;
    XEvent exppp;
    char buffer[20];
    int bufsize = 20;
    KeySym key;
    XComposeStatus compose;
    int charcount;
    XNextEvent(display, &ev);
    switch(ev.type)
    {
    case Expose:
        //printf("Expose\n");
        XPutImage(display, window, DefaultGC(display, 0), ximage, 0, 0, 0, 0, width, height);
        break;
    case KeyPress:
        //printf("key presed\n");
        charcount = XLookupString((void*)&ev,
                                   buffer, bufsize, &key, &compose);
        if(key==XK_Right)
        {
            if(x+KROK<=width-width2)
            {
                x+=KROK;
            }
        }
        else if(key==XK_Left)
        {
            if(x-KROK>=0)
            {
                x-=KROK;
            }
        }
        else if(key==XK_Up)
        {
            if(y+KROK<=height-height2)
            {
                y+=KROK;
            }
        }
        else if(key==XK_Down)
        {
            if(y-KROK>=0)
            {
                y-=KROK;
            }
        }
        else if(key==XK_plus)
        {
            if(alpha+0.05<=1.0)
            alpha+=0.05;
            else
            alpha=1.0;
        }
        else if(key==XK_minus)
        {
            if(alpha-0.05>=0)
            alpha-=0.05;
            else
            alpha=0.0;
        }
        else if(key==XK_Escape)
        {
            exit(0);
        }
        //XPutImage(display, window, DefaultGC(display, 0), ximage, 0, 0, 0, 0, width, height);
        memset(&exppp, 0, sizeof(exppp));
        exppp.type = Expose;
        exppp.xexpose.window = window;
        XSendEvent(display,window,False,ExposureMask,&exppp);
        XFlush(display);
        break;
    case ButtonPress:
        //exit(0);
        break;
    }
}




int main(int argc, char** argv)
{
    /*printf("char*: %d, short: %d, int: %d, long: %d, long long: %d, float: %d, double: %d, long double: %d\n",
           sizeof(char*),sizeof(short),sizeof(int),sizeof(long),sizeof(long long),sizeof(float),sizeof(double),sizeof(long double));
    */
    FILE* file1;
    FILE* file2;
    char* m1;
    char* m2;
    char* result;
    file1=fopen("test1.bmp", "rb");
    file2=fopen("test4.bmp", "rb");
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
    printf("start blend");
    //blend(m1,m2,alpha,result,x,y);
    /*file1=fopen("wynik.bmp", "wb");
    fwrite (result,sizeof(char),size1,file1);
    fclose(file1);*/


    XImage *ximage;
    int width= *((int*)(result+18));//undefined behavior, ale dziala na galerze
    int height= *((int*)(result+22));
    int width2= *((int*)(m2+18));
    int height2= *((int*)(m2+22));
    Display *display=XOpenDisplay(NULL);
    Visual *visual=DefaultVisual(display, 0);
    Window window=XCreateSimpleWindow(display, RootWindow(display, 0), 0, 0, width, height, 1, 0, 0);
    if(visual->class!=TrueColor)
    {
        fprintf(stderr, "Cannot handle non true color visual ...\n");
        exit(1);
    }

    ximage=CreateTrueColorImage(display, visual, result, width, height);
    XSelectInput(display, window, ButtonPressMask|ExposureMask|KeyPressMask);
    XMapWindow(display, window);
    while(1)
    {
        memcpy(result,m1,sizeof(char)*size1);
        blend(m1,m2,alpha,result,x,y);
        ximage=CreateTrueColorImage(display, visual, result, width, height);
        processEvent(display, window, ximage, width, height, width2, height2);
        XFlush(display);
    }


    return 0;
}
