#include <pthread.h>

#define WORKER_COUNT 4

typedef struct {
    int worker_id;
} worker_args_t;

static void *worker_main(void *opaque)
{
    worker_args_t *args = opaque;

    /* TODO: Use the worker argument and return a result if needed. */
    (void)args;
    return NULL;
}

int main(void)
{
    pthread_t threads[WORKER_COUNT];
    worker_args_t args[WORKER_COUNT];

    for (int index = 0; index < WORKER_COUNT; index++) {
        args[index].worker_id = index;
        /* TODO: Create each worker and handle pthread_create errors. */
    }

    for (int index = 0; index < WORKER_COUNT; index++) {
        /* TODO: Join each successfully created worker. */
    }

    return 0;
}
