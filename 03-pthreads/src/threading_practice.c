#include <pthread.h>
#include <stdio.h>
#include <string.h>

#define WORKER_COUNT 4

typedef struct {
    int worker_id;
} worker_args_t;

static void *worker_main(void *opaque)
{
    worker_args_t *args = opaque;
    printf("Worker %d is running\n", args->worker_id);
    return NULL;
}

int main(void)
{
    pthread_t threads[WORKER_COUNT];
    worker_args_t args[WORKER_COUNT];
    int created = 0;
    int status = 0;

    for (int index = 0; index < WORKER_COUNT; index++) {
        args[index].worker_id = index;

        int rc = pthread_create(&threads[index], NULL,
                                worker_main, &args[index]);
        if (rc != 0) {
            fprintf(stderr, "Cannot create worker %d: %s\n",
                    index, strerror(rc));
            status = 1;
            break;
        }

        created++;
    }

    for (int index = 0; index < created; index++) {
        int rc = pthread_join(threads[index], NULL);
        if (rc != 0) {
            fprintf(stderr, "Cannot join worker %d: %s\n",
                    index, strerror(rc));
            status = 1;
        }
    }

    return status;
}