#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* some_work(void* arg)
{
    for (int i = 0; i < 5; ++i)
    {
        puts(arg);
        sleep(1);
    }
    return NULL;
}


int main(void)
{
    pthread_t thread1, thread2;
    pthread_create(&thread1, NULL, some_work, "Hello World");
    pthread_create(&thread2, NULL, some_work, "Hello METANIT");

    pthread_exit(NULL);
    printf("End...\n");
    return 0;
}
