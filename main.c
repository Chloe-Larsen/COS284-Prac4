#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

/* ------------------------------------------------------------------ */
/* Struct definitions must match the ones in the practical sheet.     */
/* Your assembly must use the same layout:                            */
/*   State      : int id (0), bool isAccepting (4)      -> size 8     */
/*   Transition : int from (0), int to (4), char symbol (8) -> size 12 */
/*   DFA        : State* (0), Transition* (8),                        */
/*                int numStates (16), int numTransitions (20),        */
/*                int startState (24)                    -> size 32   */
/* ------------------------------------------------------------------ */
typedef struct { int id; bool isAccepting; } State;
typedef struct { int from; int to; char symbol; } Transition;
typedef struct {
    State*      states;
    Transition* transitions;
    int         numStates;
    int         numTransitions;
    int         startState;
} DFA;

/* Implemented in your assembly files. */
extern DFA* readDfa(const char* filename);
extern bool simulateDfa(DFA* dfa, const char* inputString);

/* ------------------------------------------------------------------ */
/* Optional sanity check: print the layout the C compiler is using.   */
/* Compile with -DVERIFY_LAYOUT to enable.                            */
/* ------------------------------------------------------------------ */
#ifdef VERIFY_LAYOUT
#include <stddef.h>
static void verify_layout(void)
{
    printf("sizeof(State)          = %zu\n", sizeof(State));
    printf("  offsetof(id)         = %zu\n", offsetof(State, id));
    printf("  offsetof(isAccepting)= %zu\n", offsetof(State, isAccepting));

    printf("sizeof(Transition)     = %zu\n", sizeof(Transition));
    printf("  offsetof(from)       = %zu\n", offsetof(Transition, from));
    printf("  offsetof(to)         = %zu\n", offsetof(Transition, to));
    printf("  offsetof(symbol)     = %zu\n", offsetof(Transition, symbol));

    printf("sizeof(DFA)            = %zu\n", sizeof(DFA));
    printf("  offsetof(states)     = %zu\n", offsetof(DFA, states));
    printf("  offsetof(transitions)= %zu\n", offsetof(DFA, transitions));
    printf("  offsetof(numStates)  = %zu\n", offsetof(DFA, numStates));
    printf("  offsetof(numTransitions)=%zu\n", offsetof(DFA, numTransitions));
    printf("  offsetof(startState) = %zu\n", offsetof(DFA, startState));
}
#endif

/* ------------------------------------------------------------------ */
/* Optional: dump the DFA your readDfa built, to eyeball the parse.   */
/* Compile with -DDUMP_DFA to enable.                                 */
/* ------------------------------------------------------------------ */
#ifdef DUMP_DFA
static void dump_dfa(const DFA* d)
{
    if (!d) { printf("[dump] dfa = NULL\n"); return; }
    printf("[dump] numStates=%d numTransitions=%d startState=%d\n",
           d->numStates, d->numTransitions, d->startState);
    printf("[dump] states:\n");
    for (int i = 0; i < d->numStates; i++) {
        printf("  [%d] id=%d accepting=%d\n",
               i, d->states[i].id, (int)d->states[i].isAccepting);
    }
    printf("[dump] transitions:\n");
    for (int i = 0; i < d->numTransitions; i++) {
        printf("  [%d] %d --'%c'--> %d\n",
               i, d->transitions[i].from,
               d->transitions[i].symbol,
               d->transitions[i].to);
    }
}
#endif


int main(int argc, char** argv)
{
#ifdef VERIFY_LAYOUT
    verify_layout();
    if (argc == 1) return 0;
#endif

    if (argc != 3) {
        fprintf(stderr, "usage: %s <dfa-file> <input-string>\n", argv[0]);
        return 2;
    }

    const char* filename = argv[1];
    const char* input    = argv[2];

    DFA* dfa = readDfa(filename);
    if (!dfa) {
        fprintf(stderr, "readDfa failed to open '%s'\n", filename);
        return 2;
    }

#ifdef DUMP_DFA
    dump_dfa(dfa);
#endif

    bool accepted = simulateDfa(dfa, input);
    printf("%s\n", accepted ? "ACCEPT" : "REJECT");

    /* We do NOT free dfa: the practical only specifies readDfa /
     * simulateDfa. If you want valgrind-clean runs, add a freeDfa()
     * in your asm and call it here. Not required for marking. */
    (void)dfa;
    return accepted ? 0 : 1;
}