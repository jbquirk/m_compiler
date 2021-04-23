# m_compiler
## _A micro code complier for MyCpu a TTL based 8 bit CPU._

This complier is an attempt to make generating the micro code for MyCpu less error prone. Along the way I learnt a lot this code is still quite 
buggy but does produce correct micro code. I rewrote the assembler and it's much nicer with lots of room to grow.
The assembler takes the processed output from the micro code compiler to generate the tables for the assembler.
I did this so as I change the instruction set I do not have to completely rebuilt the assembler.
This docuement by its nature will reffer to the architecture of the MyCpu as it is the mirco code builder/compiler for this cpu.
The output is current a very basic hex format the [digital]: https://github.com/hneemann/Digital simulator. 

- [m_compiler](#m-compiler)
  * [_A micro code complier for MyCpu a TTL based 8 bit CPU._](#-a-micro-code-complier-for-mycpu-a-ttl-based-8-bit-cpu-)
    + [The basic syntax](#the-basic-syntax)
    + [Read select codes](#read-select-codes)
      - [Table 2  W_SEL bits](#table-2--w-sel-bits)
    + [Table 3 Address bus selection](#table-3-address-bus-selection)
    + [Table 4 the ALU codes](#table-4-the-alu-codes)
    + [Flags mux for micro code logic](#flags-mux-for-micro-code-logic)
      - [Destination Reg codes](#destination-reg-codes)
    + [Detailed syntax of complier and usage](#detailed-syntax-of-complier-and-usage)
      - [TODO](#todo)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>


###  The basic syntax    

   **XX:** starts generation of instruction   
   **op: 0xnn ;** the start of an instruction the semi colon finish the line all valid lines must have a semi colon.  
    I have used c++ style quotes for comments as a semi colon on it own now is a syntax error.   
   **end:;** end the instruction build sequence code   
   **ram[pc]->REGA** gets dat from ram using the PC and place in REG(A)   
   **pc(inc)** this increments the PC counter this will be extend to X , Y  and SP in the up coming redesign.  
   The target of -> can be any of the following;  
   A register including the **mar[lsb],mar[msb],pc[lsb]** and so on.   
   The structure define the makeup of the micro code instruction word    

```c
struct inst_word {
				int Sreg_code 		: 4	; //bit 0-3 
				int Dreg_code		: 4 ; //Bit 4-7
				int W16 		: 1 ; //Bit 8 Saves current address to 16 bit reg 
				int DBtoALU		: 1	; //Bit 9
				int ex_alu		: 1	; //Bit 10
				int inc_pc		: 1	; //Bit 11 now increments selected 16 reg 
				int sp_func		: 2	; //Bit 12-13 
				int __sel_msb		: 1 ; //Bit 14  
				int __sel_lsb		: 1 ; //Bit 15
				int ldinst		: 1 ; //Bit 16
				int en_jmp0		: 1 ; //bit 17
				int ad_mast		: 2	; //bit 18-19
				int alu_func		: 4 ; //bit 20-23
				int alu_flags		: 3 ; //Bit 24-26
				int alu_cntrl		: 3	; //Bit 27-29
				int dec_sp		: 1 ; //Bit 30 Decrements selected register
				int _AorD    		: 1 ; //Bit 31 // Select A or d register set to ALU
			};
```

This a dynamic thing and is not yet complete for example the MyCpu current doesn't yet implement interrupts.  There is some disconnect between the structure above and the documented fields below .

The CPU as currently implemented exists as a  [digital]: https://github.com/hneemann/Digital Simulation. The ALU is based on 74LS181   

### Read select codes  

Codes to select item for output onto DB designed so only one item can output.

| **Code** | **Function notes**                                           | **Mnemonic** |
| -------- | ------------------------------------------------------------ | ------------ |
| 0        | Nothing  selected this does away with enable bit.            | None         |
| 1        | Enable  Register A onto the main data bus                    | REGA         |
| 2        | Enable  Register B onto the main data bus                    | REGB         |
| 3        | Enable  Register C onto the main data bus                    | REGC         |
| 4        | Enable  Register D onto the main data bus                    | REGD         |
| 5        | Enable  Register H onto the main data bus                    | REGH         |
| 6        | Enable  Register L onto the main data bus                    | REGL         |
| 7        | Enable read  of PC                                           | R_PC         |
| 8        | Enable read  of Y                                            | R_Y          |
| 9        | Enable read  of X                                            | R_X          |
| 10       | Enable Read  of SP  Note all 16  bit reads require LSB/MSB signal to complete bus transaction | R_SP         |
| 11       | Spare                                                        |              |
| 12       | Spare                                                        |              |
| 13       | Read ALU  flags and status reg                               | R_Flags      |
| 14       | Enable the  output of the RAM onto the data bus and A side of ALU | RAM          |
| 15       | Special  function code HALT stops all clocks                 | HALT         |

 

#### Table 2  W_SEL bits

These are expanded control bits from the control register.

 

| **Code** | **Function notes**                                           | **Mnemonic** |
| -------- | ------------------------------------------------------------ | ------------ |
| 0        | This cause  current PC to be latched into the transparent latches leave this code active  when the PC is active this allows push and PC index operations to work. | DEF          |
| 1        | Assert MSB  line to allow 8 operations on 16 bit reg         | SEL_MSB      |
| 2        | Assert LSB  line to allow 8 operations on 16 bit reg         | SEL_LSB      |
| 3        | Enables I/O  operations.                                     | I_O mode     |

 



 

### Table 3 Address bus selection

This selects the source of the Address bus

| **Code** | **Function notes**                                           | **Mnemonic** |
| -------- | ------------------------------------------------------------ | ------------ |
| 0        | The Program  Counter (PC) is used as the source for the address bus | AD_PC        |
| 1        | The Stack  Pointer (SP) is used as the source for the address bus | AD_SP        |
| 2        | The Memory  Address Register (MAR) is used as the source for the address bus | AD_MAR       |
| 3        | Address bus  disabled high Z state.                          | AD_OFF       |

 

### Table 4 the ALU codes

This is the ALU control codes it also needs the M and C bit in the control word to be set as well to control the ALU software The simulation current has a decode ROM that correctly sets the state of all control bits and the correct ALU code . Note function of the carry flag is inverted during sub functions. Note A and B are inputs to the ALU with B bus currently coming from the B register and A bus from the A register.  The ALU execute line causes the current result of the ALU operation to be written to currently active A register. See the main CPU documentation for more details. 

 

| **Mnemonic**        | **Code** | **Mbit** | **Cin** | **Carry_Ctl** | **OP_code** | **Shift** | **ALU  Code** |
| ------------------- | -------- | -------- | ------- | ------------- | ----------- | --------- | ------------- |
| ADD  A+B            | **0**    | 0        | 1       | 0             | 9           | 0         | 0029          |
| ADC  A+B            | **1**    | 0        | 1       | 1             | 9           | 0         | 0069          |
| SUB  A-B            | **2**    | 0        | 0       | 0             | 6           | 0         | 0006          |
| SUBC  A-B           | **3**    | 0        | 0       | 1             | 6           | 0         | 0046          |
| AND A  .and. B      | **4**    | 1        | 0       | 0             | b           | 0         | 001B          |
| XOR A  .xor. B      | **5**    | 1        | 0       | 0             | 6           | 0         | 0016          |
| OR A .or.  B        | **6**    | 1        | 0       | 0             | e           | 0         | 001E          |
| NOTA                | **7**    | 1        | 0       | 0             | 0           | 0         | 0010          |
| DEC A               | **8**    | 0        | 1       | 0             | F           | 0         | 002F          |
| INC A               | **9**    | 0        | 0       | 0             | 0           | 0         | 0000          |
| SLL A  with count B[^1] | **10**   | 0        | 1       | 0             | 0           | 1         | 00A0          |
| SLR A  count B[^1]  | **11**   | 1        | 0       | 0             | 0           | 1         | 0090          |
| SET A  -> FF      | **12**   | 0        | 1       | 0             | 3           | 0         | 0023          |
| CLR  A->0           | **13**   | 1        | 0       | 0             | 3           | 0         | 0013          |
| CMP A  to B         | **14**   | 0        | 1       | 0             | 6           | 0         | 0026          |
| TSTA                | **15**   | 0        | 1       | 0             | 0           | 0         | 0020          |
|                     |          | 1        | 1       | 1             | f           | 1         | 00FF          |

[^1]: Not executed in ALU

 

### Flags mux for micro code logic 

Table 5

This code selects the flag into the control rom this allows for instructions to be influenced by the the state of the flags register. 

| **Code** | **Function notes**                                          | **Mnemonic** |
| -------- | ----------------------------------------------------------- | ------------ |
| 0        | All ways zero                                               | NOP          |
| 1        | Zero Flag  select                                           | Z            |
| 2        | Carry flag  select                                          | C            |
| 3        | Equal flag  selected, note valid in compare ins only        | =            |
| 4        | Greater than  flag selected, note valid in compare ins only | GT           |
| 5        | Less than  flag selected, note valid in compare ins only    | LT           |
| 6        | Negative Flag  selected                                     | -            |

  

#### Destination Reg codes

Table 6

Codes to select item to read from DB now only one destination is allowed

 

| **Code** | **Function notes**                                           | **Mnemonic** |
| -------- | ------------------------------------------------------------ | ------------ |
| 0        | Nothing  selected this does away with enable bit.            | None         |
| 1        | Enable  Register A onto the main data bus and A side of ALU  | REGA         |
| 2        | Enable  Register B to read the main data bus and A side of ALU | REGB         |
| 3        | Enable  Register C to read the main data bus and A side of ALU | REGC         |
| 4        | Enable  Register D to read the main data bus and A side of ALU | REGD         |
| 5        | Enable  Register T to read the main data bus and A side of ALU | R_Temp       |
| 6        | Writ LSB of a  16 bit reg it doesn’t care which reg at this stage as we only have 1 16 bit  LSB holding register. | W16_LSB      |
| 7        | Write the 16 value  into the selected 16 register with LSB from holding register and MSB from the  DB. | W16_PC       |
| 8        | Write the 16  value into the selected 16 register with LSB from holding register and MSB  from the DB. | W16_SP       |
| 9        | Write the 16  value into the selected 16 register with LSB from holding register and MSB  from the DB. | W16_X        |
| 10       | Write the 16  value into the selected 16 register with LSB from holding register and MSB  from the DB. | W16_Y        |
| 11       | This codes  currently unused                                 |              |
| 12       | Write H                                                      |              |
| 13       | Write L                                                      |              |
| 14       | This codes  currently unused                                 |              |
| 15       | Enable write  to RAM                                         | W_RAM        |

 

### Detailed syntax of complier and usage

A valid instruction definition is as follows

it starts with an  

> op: 0x00

and finishes with the 

> *:end ;

In between we have instructions to actually carry the intended operations for the instructions. Now let's look at a real instruction.

```asm
op: 0x18 ; //ADC_DA_VAL 3 Add 16 bit mem to DA with carry 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(adc),inc(pc),swapBT; //LSB
*: ram[pc]->acum,alu(adc),jmp0,inc(pc),swapBT,swapAD; //MSB
*: end;
```

First the "op:0x18 ;" defines the op code we are allocating to this instruction. An error is flagged if more than one is instruction is attempted to be defined. 

The comment following "//ADC_DA_VAL 3 Add 16 bit mem to DA with carry " is not really a comment and is also required if wish to build the assembler tables. This define the Mnemonic for the instruction. This translates as follows the first part is always the mnemonic the **"_ "**   defines the end of each section. The next parts depend on the instruction in this case its a 16 bit register be added to a memory location. the number following is how many bytes the instruction needs.  in this example it needs three one byte for the instruction and two bytes for the 16 bit operand. 

The next line "*: ram[pc]->instr,inc(pc) ; //basic istruction fetch"  is present in all my instructions and shows the processor roots to be the Ben Eater concept. Its the instruction fetch.  To break it down star colon always start the line with star being any of the following  *,Z,C,=,GT,LT,neg.  

| Symbol | Meaning           | Description                                                  |
| ------ | ----------------- | ------------------------------------------------------------ |
| *      | Star              | ignore the input from the flags                              |
| Z      | Zero Flag         | Select for zero flag                                         |
| C      | Carry Flag        | Select for carry flag                                        |
| =      | Equal Flag        | Select for equal flag this only valid after the compare operation |
| GT     | Greater Than Flag | Select for greater than flag this only valid after the compare operation |
| LT     | Less than Flag    | Select for less than flag this only valid after the compare operation |
| neg    | Negative Flag     | Select for negative number                                   |

The "ram[pc]" think of this as an array where ram is the memory and pc the index.  The construct "->" means place value in.

And in the example it is the instruction decode register.  The comma tell the complier it is finished with that element of the micro instruction. Next think of it as a call to an increment function with the PC as parameter.

Next line now takes the value from the memory pointed to by the PC and places that value on the address bus in this case the target is the ALU.  The syntax acum is hold over from a previous design and now this coding just place the value on the data bus.

The next part tell the ALU to execute the ADC ALU instruction as with all instructions this will happen on the rising clock tick. 

Next we have another increment of the PC and the the strange code "swapBT" this strange code is flag and correlates to a flag in the final control word that makes the B side of the ALU the DATA bus. 

The next line is identical except for the "swapAD" code. As with the previous example this is a control flag but in this case it swaps the A and D register onto the A bus of the ALU. With these two control lines  it gives us great control over data flow to the ALU.

 

| Codes                                    | Description                                                  |      |
| ---------------------------------------- | ------------------------------------------------------------ | ---- |
| REGA","REGB","REGC","REGD","REGH","REGL" | These are the 8 bit working registers with A and D being contented to the A side of the ALU. B and C are connected to the B side.  With A and B the default registers. H and L are just 8 bit registers with no connection to the ALU. |      |
| "ram"                                    | Always used in the form ram[X] with X being one of the 16 bit registers. |      |
| "pc","sp","mar","Y"                      | The 16 bit registers. These can be targets of the inc() or dec() function note this does not go through the ALU. It is implemented in hardware. |      |
| "jmp0",                                  | Reset the micro code counter - it in effect marks the end of the instruction. |      |
| "end"                                    | Marks the formal end of the microcode instructions.          |      |
| "lsb","msb"                              | This is used select the MSB or the LSB of the 16 bit registers and places or reads the value from the data bus. coded as **pc[lsb]**. |      |

 

More to follow  



#### TODO

Add a final error message report and try clean reported errors currently it can die with out a decent diagnostic message.

- Fix syntax to avoid the need for a dangling comma in some syntax structures. 
- More options for output formats for example binary, offical intel hex.

