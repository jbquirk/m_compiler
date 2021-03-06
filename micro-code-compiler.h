// definitions for bulider
#ifndef MICRO_CODE
#define MICRO_CODE
#define EXTERN


#else
#define EXTERN extern

#endif

enum state {scan,op,inst,code,done,flags,error};

//enum ALU_INS {add=0,sub,inc,and,xor,not_b,not_a,or,add_c,sub_c,inc_c,dec_c,lsl_c,dec,lsl,cmp};
// Added a specific end tag to defifine the end of instruction generation. 
// The syntax is now: 
//XX: starts generation of instruction
//op: 0xnn ; the start of an instruction the semi colon finish the line all valid lines must have a semi colon.
// I have used c++ style quotes for comments as a semi colon on it own now is a syntax error.
// end:; end the instruction build sequenance 
// code ram[pc]->REGA gets dat from ram using the PC and plce in REG(A)
// pc(inc) this increaments the PC counter this will be extend to mar and sp in the up comming redesign.
//The target of -> can be any of the following;
// A register including the temp, mar[lsb],mar[msb],pc[lsb] and so on. 
/* these define the makeup of the instruction word 
*/
#define REG_CODES 0
#define TMP_SEL 4
#define EN_W_A 5
#define EN_W_B 6
#define EN_W_C 7
#define EN_W_D 8
#define EN_W_TMP 9
#define EN_EX_ALU 10
#define EN_INC_PC 11
#define W_SEL_A 12
#define EN_LD_LSB 14
#define EN_LDPC_MSB 15
#define EN_JMP0 17
#define SEL_AD 18
#define SEL_ALU_F 20
#define SEL_FLG 24
#define M_ALU 27
#define C_ALU 28
#define EN_CFLAG 29
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
union {
	struct inst_word instruction;
	unsigned instructionb;
} en_inst;

EXTERN int instruction_word[32]; // a map of the instruct word being built before encoded
EXTERN int inst_tag[255]; //used by compiler to keep track of bit to be added.
EXTERN long int control_rom[32768]; 
EXTERN int tok_line[80]; //Line tokenized and basic syntax checks done.
EXTERN int current_instruction;
EXTERN int current_micro_address;
EXTERN int current_micro_flag_address;
EXTERN long scanned_number; //Currently only expect to have one symbol with number active at once
EXTERN int source_def, target_def, flag_def; // these flags keep track of current mirco instruction build
EXTERN int flagcode;
EXTERN int flag_act; // just so know we have and active flag
/* misc defines  */

#define TOKEN_COUNT 67   // Number of tokens
#define FETCH 0x1080e    // Basic instruction fetch loaded into 0 to ff as default;

/* These codes are the  W_SEL 1& 2 bits */
#define LATCH_PC	0    // When this enabled the PC counter is latched on the falling edge of the clock
#define spare1		1	 // This switchs on the LSB of ADDRESS buss from LSB reg other flags for what is written 	
#define A_M			2	 // Same as above 	
#define W_RAM		3	 // Address bus and data bus are used to write to RAM

/* SEL 1 & 2 are address bus enable bits*/
#define A_PC		0	// PC counter is on address bus
#define A_SP		1	// SP
#define A_MAR		2	// X Reg is on ddress bus was MAR.
#define A_Y 		3	// Y reg.

/* Enable data on data bus some special functions are also in this list as bus is don't care.
Data 4 bits of REG_SEL lines*/
#define EN_A		1 //Read REG A
#define EN_B		2 //Read REG B
#define EN_C		3 //Read REG C
#define EN_D		4 //Read REG D
#define EN_H		5 // New H reg
#define EN_L		6 // New L reg
#define R_PC    	7 //Enable read of PC
#define EN_Y    	8 //Enable read of Y
#define EN_X    	9 //Enable read of X
#define EN_SP    	10 //Enable Read of SP
					  //Note all 16 bit reads require LSB/MSB signal
					  // to complete the bus transaction
#define SPARE1    	11
#define SPARE2    	12
#define EN_Flags	13 // This reads the flags as an 8 bit value
#define EN_RAM		14
#define HALT		15	// stop computer so really doesn't matter its here




/*				// Last combinations are current unused.
*/

/* Flags bit position */
#define Zero  		0
#define Carry 		1
#define equal 		2
#define greaterthan	3
#define lessthan	4
#define Neg			5

/*ALU Flags after test tying to multiplex ALU_CODE and flags caused logic issues so extended control reg to 32 bits.
*/ 
/* Write reg values these are direct enables this allows for block writes Is this of value? */
/*

*/
#define REG_EN		4	//Enable reg select swap B and Temp Reg
#define WA			1
#define WB			2
#define WC			3
#define WD			4
#define WH			12
#define WL			13
#define Wtemp		5
#define ALU_EX		11	//skipped one select line here
#define EN_PC		12
#define LD_LSBPC 	14  //Another select line
#define LD_PC		15
#define LDI			16 //Load instruction
#define END_I		17 //Jmp0
#define TRUE		-1
#define FALSE		0
/*
#define REG_EN
#define WA
#define WB
#define WC
#define WD
#define Wtemp
#define ALU_EX
#define EN_PC
#define LD_LSBPC
#define LD_PC
#define LDI
#define RST_MICRO
*/

/*enum mirco_codes {_Latch_PC,_W_SP,_W_MAR,_W_RAM, _A_PC,_A_SP,_A_MAR,_EN_A,_EN_B,_EN_C,_EN_D,_EN_temp,_EN_ALU,_EN_RAM,_A_LSB\
                          ,_A_MSB,_HALT,_PC_LSB,_PC_MSB,_Zero,_Carry,_equal,_greaterthan,_lessthan,_Neg,_REG_EN,_WA,_WB,_WC\
						,_WD,_Wtemp,_ALU_EX,_EN_PC,_LD_LSBPC,_LD_PC,_LDI,_END_I} ;

//char *menomics[] = {"Latch_PC","W_SP","W_MAR","W_RAM", "A_PC","A_SP","A_MAR","EN_A","EN_B","EN_C","EN_D","EN_temp","EN_ALU","EN_RAM","A_LSB"\
                          ,"A_MSB","HALT","PC_LSB","PC_MSB","Zero","Carry","equal,_greaterthan","lessthan","Neg","REG_EN","WA","WB","WC"\
						,"WD,_Wtemp","ALU_EX","EN_PC","LD_LSBPC","LD_PC","LDI","END_I"} ;
*/
enum mirco_codes { star=1,colon,z,c,eq,gthan,lthan,_neg,A,B,C,D,H,L,SC,SD,\
					_alu,acum,swap,swapAD,lb,rb,\
					comma,semi,_ram,_pc,_sp,_mar,_Y,T,_F,_M\
					,_lsb,_msb,under,_a,_add,_adc,_sub,_sbc,_and,_xor,_or,_nota,_dec,_inc,_sll,_slr,_set,_clr,_cmp,_tst,_src,_op\
					,jmp0,save,bang,instr,nop,write,halt,point,lbr,rbr,end,comment,num };


EXTERN struct parser_var { int mstate;
							int index; 
							};
								
EXTERN struct p_state 	{ struct parser_var s;
						int tok;
						}; 
int encode_dec(int index);
