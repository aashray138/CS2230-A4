# Assignment Four: Color Cycle

### Objective

For this assignment, you should try to cycle through the available colors on your RGB LED slowly and, when the onboard switch is pressed, display the current color to the screen using `cio_printf()`. The following colors should be displayed **in the given order**:

1. Off
1. Green
1. Red
1. Purple
1. Yellow
1. Blue
1. White
1. Cyan

Here is sample output from `screen`/`minicom`:

    > OFF
    > GREEN
    > RED
    > PURPLE
    > YELLOW
    > BLUE
    > WHITE
    > CYAN

##### Note: `OFF` is considered a "color" for the purposes of the assignment

You should use an _interrupt_ to print the name of the color to the screen while the main loop consists of cycling through the colors with a small delay in between.

You will need to set up _two arrays_ for this assignment. The template includes the format string that should be used with the `cio_printf()` function. Also [read below](#memory-alignment) about the `.p2align` assembler directive.

All the button interrupt has to do is print out the current color. The strategy will be similar to the previous assignment. **Writing code as general as possible is a very important skill to learn.** Hard-coding values can cause bugs when you inevitably have to modify the code later.

When you have an issue or you are getting unexpected results, _reach for the debugger_. This is your best view into how the CPU is operating at any given moment. Confirm the contents of registers or the arguments of function calls. There are many resources available on different `gdb` commands, but I've [tried to collect important ones here](https://maccreery.cs.wmich.edu/cs2230/linux/compiler_and_debugger/).

### Using the Stack

To properly call the `cio_printf()` function, you will need to **push** arguments onto the stack. The reason for this is because `cio_printf()` is a [variadic function](https://en.wikipedia.org/wiki/Variadic_function) because it takes _at least_ a format string as the first argument and then _any number of arguments after that_. Because of this behavior, instead of placing arguments to be passed to the function in the registers `r15`, `r14`, `r13` and `r12`, we will need to put all arguments onto the stack **in reverse order**.

This means that the format string should be the _last_ thing that is put onto the stack. Remember, [the stack is a last-in-first-out (LIFO)](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) data structure.

The assembly instructions `push` and `pop` will need to be utilized here. You also need to _think about what these instructions do to the stack pointer `r1`_. Remember that the **stack pointer** is where the **return address** is stored for function calls (and interrupts, which basically are functions called by the hardware itself). So if this pointer is out of position when a `ret` instruction is executed **you will cause a crash**. Or, at least, we hope it would cause a crash, but since this is a microcontroller it will often result in strange or unintended behavior. Pay close attention to what you are telling the CPU to do!

### Memory Alignment

It seems we didn't need to talk about this in the previous assignment, although some students did use this on their own, but there is a directive that will ensure the assembler positions data on _an even memory addresses_ when we are arranging things in memory. That is the [`.p2align` directive](https://sourceware.org/binutils/docs/as/P2align.html#P2align). Specifically **we want to use `.p2align 1,0`** after we have set up our strings for the color names. This will ensure the array of addresses (and following data) all reside on even memory addresses. This is _critical_ for the `push` instruction to behave as we expect.

