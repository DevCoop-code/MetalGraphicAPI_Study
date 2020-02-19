# Performing Calculations on a GPU
Use Metal to find GPUs and perform calculations on them

## Overview
What to learn from this project
- How to convert a simple function written in C to Metal Shading Language(MSL) so that it can be run on a GPU
  - Find GPU, Prepare the MSL function to run on it by creating a pipeline, and create data objects accessible to the GPU
  - To execute the pipeline against your data, create a command buffer, write commands into it, and commit the buffer to a command queue
  - Metal sends the commands to the GPU to be executed

## Write a GPU Function to Perform Calculations
Below is the C Style on the CPU
![C-Style-Func](./ImageWarehouse/C_Style_Func.png)
Each value is calculated independently, so the values can be safely calculated concurrently.
<br><br>
To Perform the calculation on the GPU, need to rewrite this function in Metal Shading Language(MSL)
Below is the same function written by Metal.<br>
In Metal, code that runs on GPUs is called a shader
![Metal-Style-Func](./ImageWarehouse/Metal_Style_Func.png)
<br><br>
Different of C Style Func and Metal Style Func
- Metal Style Function adds the kernel keyword, which declares that the function is:
  - A public GPU Function. Public functions also can't be called by other shader functions
  - A compute function, which performs a parallel calculation using a grid of threads

Analysis the MSL Function
- device keyword
  - device keyword says that these pointers are in the device address space. Whenever declare a pointer in MSL, you must apply a keyword to declare its address space. Use the device address space to declare persistent memory that the GPU can read from ad write to
- Removes the for-loop
  - function is now going to be called by multiple threads in the compute grid.
- To replace the index previously provided by the for-loop, function takes a new index argument, with another MSL keyword, <b>thread_position_in_grid</b>, specified using C++ attribute syntax
  - "thread_position_in_grid" keyword: Declares that Metal should calculate a unique index for each thread and pass that index in this argument.

## Find a GPU
<b>MTLDevice</b> object is a thin abstraction for a GPU; you use it to communicate with a GPU. Metal creates a MTLDevice for each GPU. To get the default device object, calling <b>MTLCreateSystemDefaultDevice</b>
![MTLCreateSystemDefaultDevice](./ImageWarehouse/FindDefaultGPU.png)
<br>

## To get information about Metal libraries and the functions
- MTLLibrary: A collection of Metal Shader Functions
  - MTLLibrary object contains Metal Shading language source code
- MTLFunction: An object representing a public shader function in the library
  - MTLFunction object is considered a specialized function

## Prepare a Metal Pipeline
To execute MSL function, you convert the function into executable code by creating a pipeline.<br>
A Pipeline specifies the steps that the GPU performs to complete a specific task.<br>
In Metal, a pipeline is represented by a <b>Pipeline State Object(PSO)</b>

## Create a Command Queue
To send work to the GPU, need a command queue. Metal uses command queues to schedule commands

## Create Data Buffers and Load Data
After initializing the basic Metal objects, need to load data for the GPU to execute.<br>
A GPU can have its own dedicated memory, or it can share memory with the operating system.<br>
Metal abstracts this memory management using resource objects.(<b>MTLResource</b>)<br>
The resource are may be <b>MTLBuffer</b> objects, which are allocations of memory without a predefined format.

## Create a Command Buffer
Ask the command queue to create a command buffer

## Create a Command Encoder
To write commands into a command buffer, use a command encoder for the specific kind of commands you want<br>
![MTLCommands](./ImageWarehouse/Commands.png)

## Reference
https://developer.apple.com/documentation/metal/basic_tasks_and_concepts/performing_calculations_on_a_gpu?preferredLanguage=occ