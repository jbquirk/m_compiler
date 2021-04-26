 /****************************************************************************
 *                                                                          *
 * File    : main.c                                                         *
 *                                                                          *
 * Purpose : Console mode (command line) program.                           *
 *                                                                          *
 * History : Date      Reason                                               *
 *           00/00/00  Created                                              *
 *                                                                          *
 ****************************************************************************/

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdbool.h>
#include "micro-code-compiler.h"
/* Defined codes
*/
char *M_STATE [] = {"scan","op","inst","done","flags"};
char *menomics[] = {"*",":","Z","C","=","GT","LT","neg","REGA","REGB","REGC","REGD","REGH","REGL","SC","SD"\
					,"alu","acum","swapBT","swapAD","(",")",",",";","ram","pc","sp","mar","Y","REGT","FLAGS","M16"\
					,"lsb","msb","_","_a","add","adc","sub","sbc","and","xor","or","nota","dec","inc","sll"\
					,"slr","set","clr","cmp","tst","src","op","jmp0","save","!","instr","nop","write","halt","->","[","]","end","//","number" };
				
int ALU_CODES[]= {		 0x29, 0x69,  0x06, 0x46,0x00, 0x15,   0x10,   0x1a, 0x5a,	0x26,0x1b, 0x1e,0x16,0x2f,0x13,0x53};
#define NUM_ALU_CODES 16          // due to limitation initialized in main
//int alu_mnemonics[NUM_ALU_CODES] = {_add,_adc,_sub,_sbc,_inc,_notb,_nota,_sll,_slc,_cmp,_and,_or,_xor,_dec,_slr,_src};
//
//
struct parser_var state;
int processline(int m_state);
struct parser_var parse_line(struct parser_var s); 
int tokenize_line(char *buf);
char *convert_num(char *buf, int i);
struct parser_var encode_alu(struct parser_var s);
int encode_jmp0(int index);
int encode_inc(int index);
int encode_halt(int index);
struct parser_var encode_source_t(struct parser_var s);
int encode_flags(int index,int flag);
struct parser_var build_instr(struct parser_var s); 
void print_tok_line(int t[]);
struct parser_var parse_instruction(struct parser_var s);
struct parser_var parse_flags(struct parser_var s);
int process_brackets(struct p_state *p, int tok);
void cleanup(void); //
void clear_inst( void);
void dumpHex(void);
void initHex(void);
long line_cnt; // keep track of line number processing

/****************************************************************************
 *                                                                          *
 * Function: main                                                           *
 *                                                                          *
 * Purpose : Main entry point.                                              *
 *                                                                          *
 * History : Date      Reason                                               *
 *           00/00/00  Created                                              *
 *                                                                          *
 ****************************************************************************/
line_cnt =0;

int main(int argc, char *argv[])
{
	char buf[128];
 //   char *b = buf,b2;
    size_t bufsize = 128;
 	FILE *fp;
	int m_state = scan;
   
   /* opening file for reading */
   fp = fopen(argv[1] , "r");
   if(fp == NULL) {
      perror("Error opening file");
      return(-1);
	}
    source_def = target_def = flag_def = flag_act = FALSE; // Clear flags
	clear_inst();
	initHex();
 //	printf("%s %x ALU Code = %x\n",alu_mnemonics[inc],inc, ALU_CODES[inc]);
	while(fgets(buf,bufsize,fp)!=NULL)
	{
		line_cnt++;
		printf("%6d ",line_cnt);
//		b2 = buf;
		if(!tokenize_line(buf)) // we line lets tokenize before sending to parser
			{
			printf("Error found in line %d\n", line_cnt);
			// line is bad so we need to skip to next line
			cleanup(); // tidy half bulit structures. 

			} else if( tok_line[0] == 0 || tok_line[0] == comment) {
//			printf("Empty line: skip line %d\n",line_cnt);
			} else {
				m_state = processline(m_state);
			}
		printf("%s",buf);	
	}
	dumpHex();
    return 0;
}
/*
Some quick thoughts on the parser stage currently it breaks to often and gets out of sync 
so to fix I intend to resdesign as follows:
This stage will be converted to have access to the state structure and call the two stages of code generation:
we have looking for the op code def this is first stage if this fails we stay in scan after error clean up.
Next we have the code that bulid the micro instruction the most complex part of this simple program.
This phase will be split into two sections as it now but called from a subroutine from here it will have four internal states.
flags, error,done,instr.
Flags - checks that flags section is correct retruns instr, error
instr - checks instruct corrrect and returns error,done

From this I have added an extra flag called error istean of using scan this is so we know at each stage that an error has 
occured durring processing of that stage. This so stages up the tree can do error recovery as required.
Tokenize moved out of the parser stage
*/ 
// Processline holds the top level state machine the only states it deals with are scan,op,inst, error, done 
int processline(int m_state) 
{
//		static int op_code;
//		static int address;
//		int i=0;
		state.index =0;
		state.mstate = m_state;
//		printf("mstate = %s\n",M_STATE[m_state]);
		if (op == state.mstate)
				{
				state = parse_flags(state);
				if(state.mstate == inst) //generated code 
					state = build_instr(state); //some valid code found
				} 
		if( scan == state.mstate )
			{	
           	state = parse_line(state);
			}
		if(state.mstate == done) //this can come from preeceeding stages means code correct
			{
//			printf("reached done state\n");
			state.mstate=scan; // this code done look for the next
			cleanup();
			current_micro_address = 0;
 			current_instruction = 0;
			current_micro_flag_address =0;
			flag_act = FALSE;
			}
		if(state.mstate == error ) // something has gone wrong 
		{
			cleanup(); // should have been called but just in case 
			state.mstate = scan;
			current_micro_address = 0;
 			current_instruction = 0;
			current_micro_flag_address =0;

		}

	return(state.mstate);
}
struct parser_var parse_line(struct parser_var s)
{
	int m_state = s.mstate;
	int index=0; //Index pointer to tokenized line;
	while(tok_line[index] !=0) //process the line
		{
			if(m_state == scan) // looking for opcode def
			{
//				printf("OP? = %d opcode = %d %s %s\n",tok_line[index],_op,menomics[_op-1],menomics[tok_line[index]-1]);
//				print_tok_line(tok_line);
				if(tok_line[index] == _op) //found op
					{
//					printf("Colon = %d OP = %d tok = %d",colon,_op,tok_line[index+1]);
					if(tok_line[index+1] == colon && tok_line[index+3] == semi) // check syntax
						{
							if(inst_tag[scanned_number] == 1){
								printf("syntax error in line %d instruction already defined\n",line_cnt);
								m_state = error;
								s.index = index;
								s.mstate = m_state;
								cleanup();
								} else {
							inst_tag[scanned_number] = 1; // begin instruction definition
							current_instruction = scanned_number;
							current_micro_address = 0;
							m_state = op;
							//print_tok_line(tok_line);
							s.index = index;
							s.mstate = m_state;
							}
						}
					else{
						//print_tok_line(tok_line);
						if(tok_line[index+1] != colon)
							{	
							printf("expected ':' in line %d in opcode definition\n",line_cnt);
							//printf("     ^\n");
							}	
						else if (tok_line[index+3] != semi)
							{
							printf("expected ';' in line %d in opcode definition\n", line_cnt);
							//printf("               ^\n");
							}

						else
							printf("unkown error in line %d in opcode definition\n", line_cnt);
						m_state = error; // continue to scan for valid op code def
						cleanup(); // clean up any part bulit instructions.
						break;
						}
					}
			}
		index++;
	}
	s.mstate = m_state;
	s.index = index;	
	return(s);
}
int tokenize_line(char *buf)
{

	int x;
	int line_pointer = 0;
	int tok_found = FALSE;
	int skip_line = FALSE; 	
	
	while(*buf != '\n' && !skip_line)
	{
		tok_found = FALSE;
		while(isspace(*buf))
			buf++;	//skip any whitespace
			if(isdigit(*buf) )
				{
					buf = convert_num(buf,line_pointer);
					tok_found = TRUE;
					tok_line[line_pointer] = num;	
				}
			else
				for(x = 0; x < TOKEN_COUNT; x++)
				{
					if ( strncmp(menomics[x], buf, strlen(menomics[x])) == 0)
					{
						tok_line[line_pointer] = x+1; //install token in tokenized array
//						printf("found valid token %s\n",menomics[x]);
						buf = &buf[strlen(menomics[x])];
						tok_found = TRUE;
						if (x+1 == semi || x+1 == comment)
						{
							skip_line = TRUE; //semi colon ends line so skip the rest
						}
						break;
					}
				}
//		printf("x=%d\n",x);
		if(!tok_found) //syntax error
			{
			tok_line[line_pointer] =0; //Close line 	
			return(FALSE);
			}
		else
			line_pointer++;
		//buf++;

	}
	tok_line[line_pointer]=0; //close current line
	return(TRUE);
}
// try and convert string passed to number and place in token array
char *convert_num(char *buf,int i)
{
		long number;
		char *t;
		number = strtol(buf,&t,16);
//		printf("found number %ld\n",num);
		scanned_number = number;
		return(t); 
}
/* This code bulids the correct bits from the ALU instruction.
Source should be on data buss reg 'B' or temp are the b side of the ALU
This sets up flags and exute bit 
Code first checks valid syntax from table 
Current the ALU control is split over two segments this is not good and will be fixed 
but for now I will code the split. the better solution is a control rom but these 
are almost impossibile to find now. 
ALU syntax is as for the inc instruction:
alu(function)[,;] index will point to last 
The ALU has been completly redesigned it now just takes the raw opcode and now internal sorts out all the flags 
The A and B busses are now had wired directly to the A and B registers the output also is clocked back into 
currently active A registers. 
*/


struct parser_var encode_alu(struct parser_var s)
{
	struct p_state tp;
	s.index++; // the top level instruction parser is current token 
	tp.s = s;
	process_brackets(&tp,lb);
	if ( tp.tok != -1)
		{
		en_inst.instruction.alu_func = tp.tok - _add;
//		instruction_word[SEL_ALU_F]=tp.tok - _add; //these are just place holders
//        en_inst.instruction.alu_cntrl = (ALU_CODES[tp.tok - _add] >> 4);
//		instruction_word[M_ALU] = (ALU_CODES[tp.tok - _add] >> 4);
		if(tp.tok  == _cmp) 
			en_inst.instruction.sp_func = 1; // just save flags
		else
			en_inst.instruction.ex_alu = 1; // excute alu next clk
 		}
	 // fix that flags expect to point to last valid token
	s = tp.s; 
	s.index--; //adjust back to top understanding FIXME
	return s;
}
int encode_jmp0(int index)
{
	en_inst.instruction.en_jmp0 = 1; 
	instruction_word[EN_JMP0]=1; //these are real but need error checking
//	current_micro_address =0;
	return index;
}
int encode_inc(int index)
{
	en_inst.instruction.inc_pc = 1;
	switch(tok_line[index+2]) // should be 16 bit reg
	{
			case _pc:
				en_inst.instruction.ad_mast =A_PC;
				break;
			case _sp:
				en_inst.instruction.ad_mast =A_SP;
				break;
		 	case _mar:
				en_inst.instruction.ad_mast =A_MAR;
				break;
			case _Y:
				en_inst.instruction.ad_mast =A_Y;
				break;
	}
	instruction_word[EN_INC_PC]=1; //these are real but need error checking
	return index+3;  // A quick hack to skip (PC) FIXME
}
int encode_dec(int index)
{
	en_inst.instruction.dec_sp = 1;
	switch(tok_line[index+2]) // should be 16 bit reg
	{
			case _pc:
				en_inst.instruction.ad_mast =A_PC;
				break;
			case _sp:
				en_inst.instruction.ad_mast =A_SP;
				break;
		 	case _mar:
				en_inst.instruction.ad_mast =A_MAR;
				break;
			case _Y:
				en_inst.instruction.ad_mast =A_Y;
				break;
	} // not sure if this works here yet
	return index+3;  // A quick hack to skip (SP) FIXME
}
int encode_halt(int index)
{
	en_inst.instruction.Sreg_code = HALT;
	instruction_word[REG_CODES]= HALT; //these are real but need error checking
	return index;  // 
}
int encode_flags(int index, int flag)
{
	// flags z,c,eq,gthan,lthan,_neg
	int base;

	base = (flag - z)+1;
	en_inst.instruction.alu_flags = base;
	instruction_word[SEL_FLG]= base;	
	return index; //
}

// This routine dumps the token in the current token array this cross checks to if line tokenized correctly
void print_tok_line(int t[])
{
	int i=0;

	if(t[i] != 0) // token(s) in this line
	{
		while(t[i] != 0 ) // dump tokens
		{
			
			printf(" %s ",menomics[t[i]-1]);
			if(t[i] == num) // special processing for opcode define
				printf("=%x ",scanned_number);

			i++;
		}
	}
	printf("\n");
}
// The code here cleans up the internal state of the parser 
// basical if called we abort the processing of any current instruction
// If instruction def is started we don't reset the found flag
void cleanup(void)
{
		source_def = target_def = flag_def = FALSE; // clear flags
		//print_tok_line(tok_line); // dump current line may give clue as to issue.
		for( int i=0; i<32; i++)
			instruction_word[i] =0; // clear instruction word 
//		current_micro_address = 0;
 
}
void clear_inst( void)
{
				en_inst.instruction.Sreg_code	=0;
				en_inst.instruction.Dreg_code 	=0;
				en_inst.instruction.DBtoALU		=0	;
				en_inst.instruction.ex_alu		=0	;
				en_inst.instruction.inc_pc		=0	;
				en_inst.instruction.sp_func		=0	;
				en_inst.instruction.alu_func	=0 ;
				en_inst.instruction.alu_flags	=0 ;
				en_inst.instruction.alu_cntrl	=0	;
				en_inst.instruction._AorD		=0	;
				en_inst.instructionb =0;

}

