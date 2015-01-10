#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include<X11/X.h>
#include<X11/Xlib.h>
#include<GL/gl.h>
#include<GL/glx.h>
//#include<GL/glu.h>



int blend(char* a,char* b,float c,char* d, int x, int y);


Display                 *dpy;
Window                  root;
GLint                   att[] = { GLX_RGBA, GLX_DEPTH_SIZE, 24, GLX_DOUBLEBUFFER, None };
XVisualInfo             *vi;
Colormap                cmap;
XSetWindowAttributes    swa;
Window                  win;
GLXContext              glc;
XWindowAttributes       gwa;
XEvent                  xev;




int main(int argc, char** argv)
{
    printf("start blend0");
    FILE* file1;
    FILE* file2;
    long int size1, size2;
    char* m1;
    char* m2;
    char* result;
    float alpha=0.4;
    int x=0,y=0;//w pixelach
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
    blend(m1,m2,alpha,result,x,y);
    file1=fopen("wynik.bmp", "wb");
    fwrite (result,sizeof(char),size1,file1);
    fclose(file1);


    dpy = XOpenDisplay(NULL);

 if(dpy == NULL) {
        printf("\n\tcannot connect to X server\n\n");
        exit(0);
 }

 root = DefaultRootWindow(dpy);

 vi = glXChooseVisual(dpy, 0, att);

 if(vi == NULL) {
        printf("\n\tno appropriate visual found\n\n");
        exit(0);
 }
 else {
        printf("\n\tvisual %p selected\n", (void *)vi->visualid); /* %p creates hexadecimal output like in glxinfo */
 }


 cmap = XCreateColormap(dpy, root, vi->visual, AllocNone);

 swa.colormap = cmap;
 swa.event_mask = ExposureMask | KeyPressMask;

 win = XCreateWindow(dpy, root, 0, 0, 600, 600, 0, vi->depth, InputOutput, vi->visual, CWColormap | CWEventMask, &swa);

 XMapWindow(dpy, win);
 XStoreName(dpy, win, "VERY SIMPLE APPLICATION");

glc = glXCreateContext(dpy, vi, NULL, GL_TRUE);
glXMakeCurrent(dpy, win, glc);

glEnable(GL_DEPTH_TEST);
glMatrixMode(GL_MODELVIEW);
//float mapa[10000][4];

 while(1) {
        XNextEvent(dpy, &xev);

        if(xev.type == Expose) {
                XGetWindowAttributes(dpy, win, &gwa);
                glClear( GL_COLOR_BUFFER_BIT );
                glRasterPos2i( 0, 0 );
                glDrawPixels(685,441,GL_RGB,GL_UNSIGNED_BYTE,result);
                //glDrawPixels(100,100,GL_RGB,GL_FLOAT,mapa);
                glFlush();

                glXSwapBuffers(dpy, win);
        }

        else if(xev.type == KeyPress) {
                glXMakeCurrent(dpy, None, NULL);
                glXDestroyContext(dpy, glc);
                XDestroyWindow(dpy, win);
                XCloseDisplay(dpy);
                exit(0);
        }
    } /* this closes while(1) { */


    return 0;
}
