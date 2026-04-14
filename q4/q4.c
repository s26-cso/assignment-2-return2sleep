#include <stdio.h>
#include <dlfcn.h>

int main() {
    char op[6],path[20];
    int n1,n2;
    while (scanf("%s %d %d",op,&n1,&n2)==3) {
        sprintf(path,"./lib%s.so",op);
        void *h = dlopen(path,RTLD_NOW);
        if(!h){
            fprintf(stderr,"Error: Could not load %s\n",path);
            continue;
        }
        int (*f)(int,int)=dlsym(h, op);
        if(!f){
            fprintf(stderr,"Error: Could not find function %s\n",op);
            dlclose(h);
            continue;
        }
        printf("%d\n",f(n1,n2));
        dlclose(h);
    }
    return 0;
}
