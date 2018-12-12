```c
#include <stdio.h>
#include <unistd.h>

#define ONE_MB (1024 * 1024)

int main()
{
    printf("The number of processors configured is :%ld\n",
        sysconf(_SC_NPROCESSORS_CONF));
    printf("The number of processors currently online (available) is :%ld\n",
        sysconf(_SC_NPROCESSORS_ONLN));
    printf ("The pagesize: %ld\n", sysconf(_SC_PAGESIZE));  
    printf ("The pagesize: %ld\n", getpagesize());  
    printf ("The number of pages: %ld\n", sysconf(_SC_PHYS_PAGES));  
    printf ("The number of available pages: %ld\n", sysconf(_SC_AVPHYS_PAGES)); 
    printf ("The memory size: %lld MB\n", 
        (long long)sysconf(_SC_PAGESIZE) * (long long)sysconf(_SC_PHYS_PAGES) / ONE_MB );  
    printf ("The number of files max opened:: %ld\n", sysconf(_SC_OPEN_MAX));  
    printf("The number of ticks per second: %ld\n", sysconf(_SC_CLK_TCK));  
    printf ("The max length of host name: %ld\n", sysconf(_SC_HOST_NAME_MAX));  
    printf ("The max length of login name: %ld\n", sysconf(_SC_LOGIN_NAME_MAX)); 
    printf ("The number of cpu: %ld\n", sysconf(_SC_NPROCESSORS_ONLN)); 
    return 0;
}
```