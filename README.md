# m_compiler
## _A micro code complier for MyCpu a TTL based 8 bit CPU._

This complier is an attempt to make generating the mirco code for MyCpu less error prone. Along the way I learnt a lot this code is quite 
buggy and is rather bad but it gets the job done. I rewrote the assembler and it's much nicer with lots of room to grow.
The assembler takes the processed output from the mirco code compiler to generate the tables for the assembler.
I did so as I changed the instruction set I didn't to completely rebulid the assembler.

 


The syntax is now: 
XX: starts generation of instruction
op: 0xnn ; the start of an instruction the semi colon finish the line all valid lines must have a semi colon.
 I have used c++ style quotes for comments as a semi colon on it own now is a syntax error.
end:; end the instruction build sequenance code 
ram[pc]->REGA gets dat from ram using the PC and plce in REG(A)
pc(inc) this increaments the PC counter this will be extend to mar and sp in the up comming redesign.
The target of -> can be any of the following;
A register including the temp, mar[lsb],mar[msb],pc[lsb] and so on. 
these define the makeup of the instruction word 

struct inst_word {
				int Sreg_code 	: 4	; //bit 0-3 
				int Dreg_code	: 4 ; //Bit 4-7
				int W16 		: 1 ; //Bit 8 Saves current address to 16 bit reg 
				int DBtoALU		: 1	; //Bit 9
				int ex_alu		: 1	; //Bit 10
				int inc_pc		: 1	; //Bit 11 now increments selected 16 reg 
				int sp_func		: 2	; //Bit 12-13 
				int __sel_msb	: 1 ; //Bit 14  
				int __sel_lsb	: 1 ; //Bit 15
				int ldinst		: 1 ; //Bit 16
				int en_jmp0		: 1 ; //bit 17
				int ad_mast		: 2	; //bit 18-19
				int alu_func	: 4 ; //bit 20-23
				int alu_flags	: 3 ; //Bit 24-26
				int alu_cntrl	: 3	; //Bit 27-29
				int dec_sp		: 1 ; //Bit 30 Decrements selected register
				int _AorD    	: 1 ; //Bit 31 // Select A or d register set to ALU
			};