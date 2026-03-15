#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct Node {
    int value;
    struct Node *next;
} Node;

Node *node_new(int value) {
    Node *n = malloc(sizeof(Node));
    if (!n) return NULL;
    n->value = value;
    n->next  = NULL;
    return n;
}

void list_push(Node **head, int value) {
    Node *n = node_new(value);
    n->next = *head;
    *head   = n;
}

void list_free(Node *head) {
    while (head) {
        Node *next = head->next;
        free(head);
        head = next;
    }
}

int main(void) {
    Node *list = NULL;
    for (int i = 1; i <= 5; i++) list_push(&list, i);

    for (Node *n = list; n; n = n->next) {
        printf("%d\n", n->value);
    }

    list_free(list);
    return 0;
}
