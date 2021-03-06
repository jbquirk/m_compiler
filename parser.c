//
//These files split from the main source code
//
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include "micro-code-compiler.h"
int processline(int m_state);
int parse_line(int m_state); 
int tokenize_line(char *buf);
char *convert_num(char *buf, int i);
struct parser_var encode_alu(struct parser_var s);
int encode_jmp0(int index);
int encode_inc(int index);
int encode_swap(int index);
int encode_swapAD(int index);
struct parser_var encode_source_t(struct parser_var s);
int encode_flags(int index, int flag);
struct parser_var build_instr(struct parser_var s);
void print_tok_line(int t[]);
struct parser_var parse_instruction(struct parser_var s);
struct parser_var parse_flags(struct parser_var s);
int get_address_s(int tok);
void cleanup(void); // cleans up parsers intrenal state as we had an error 
int process_brackets(struct p_state *p, int tok);
int encode_halt(int index);
int encode_save(int index);
void dumpHex(void);
void initHex(void);

extern long line_cnt; // keep track of line number processing
extern char *menomics[];



struct parser_var parse_flags(struct parser_var s)
{
	int m_state = s.mstate;
	int index = 0;
	while(tok_line[index] !=0 && tok_line[index] != comment) //process the line
		{

		if(m_state == op)
			switch(tok_line[index++]){
					case star: //No action required except to switch state to code
							if( tok_line[index] != colon ) //then syntax error
							{
							printf("expected ':' in line %d in mirco instruction definition\n",line_cnt);
							printf("     ^\n");
							s.mstate=error;
							}
							s.mstate = flags;
							break;
		
					case z:
					case c:
					case eq:
					case _neg:
					case gthan:
					case lthan:
							if( tok_line[index] != colon ) //then syntax error
							{
								printf("expected ':' in line %d in mirco instruction definition\n",line_cnt);
								printf("     ^\n");
								s.mstate=error;
							}
							if(!flag_act) // once a flag is set the complier will expect a pair of instructions
								{		
								current_micro_flag_address = current_micro_address; // This will checked at the end
								flag_act = TRUE;			
								}
							flag_def = TRUE;
							flagcode = tok_line[index-1];
							index = encode_flags(index,flagcode); //this function alters working micro code address if required
							s.mstate = flags;
						break;
					case bang: // this is the code for flag not set should follow flag instruction. Need at least one.
							if( tok_line[index+1] != colon ) //then syntax error
							{
							printf("expected ':' in line %d in mirco instruction definition\n",line_cnt);
							printf("     ^\n");
							s.mstate=error;
							}
							if(current_micro_flag_address == 0) // once a flag is set the complier will expect a pair of instructions
								{ // flag instruction needs to come first
								printf("expected previous defined flag line %d in mirco instruction definition\n",line_cnt);
								s.mstate=error;
								 }
							if(flagcode != tok_line[index])
								{ // flag instruction needs to come first
								printf("Flag differnt should be the same in line %d in mirco instruction defition\n",line_cnt);
								s.mstate=error;
								}
							index = encode_flags(index,flagcode); //this function alters working micro code address if required
							index++; 
							s.mstate = flags;
							break;
					case semi:
							s.mstate =error; // did not expect semi colon here
							printf("unexpected ';' in line %d in mirco instruction definition\n",line_cnt);
						break;
					default: 
							// if here no valid flags found throw errror
						s.mstate = error;
						printf("expected valid flag def in line %d \n",line_cnt);
						break;
	
				}
		if(s.mstate == error)
			{
			s.mstate=scan;
			cleanup(); // recover from error 
			tok_line[index] =0; //force end of processing.
			}
		else
			{
			s.index = index+1; // move to next token
			s = parse_instruction(s); 			
			index = s.index;
			}
		}
	return(s);
}
struct parser_var parse_instruction(struct parser_var s)
{
//	int m_state = s.mstate;
//	int index = s.index;

	while(tok_line[s.index] !=0 ) //process the line
		{
		
			switch(tok_line[s.index]) //we are look for ALU,jmp0, comma and inc all others become source -> destination
				{
					case _alu:
							s.mstate = code;
							s = encode_alu(s);
							break;
					case swap: // this swaps the B side of ALU to Data bus defualt is B/C reg 
							s.mstate = code;
							s.index = encode_swap(s.index);
							break;
					case swapAD: // this places the CD reg on ALU B and A bus 
							s.mstate = code;
							s.index = encode_swapAD(s.index);
							break;
					case save: // this encodes 16 bit save function
							s.mstate = code;
							s.index = encode_save(s.index);
							break;
					case comma: 	// just ignore hopefully valid before 

							break;
					case jmp0:
//							printf("At jump0\n");
							s.mstate = code; //This instruction done
							s.index = encode_jmp0(s.index); //jmp0 must be the last instrcution as it generates code and clean up
							break;
					case end:
							s.mstate = done; //this code for this inst is complete note we ingnore every thing after this code.
							break; //FIXME dead terminal
					case _inc:
							s.index = encode_inc(s.index);
//							printf("found inc instruction\n");
						break; 
					case _dec: // if found here must 16 bit dec
							s.index = encode_dec(s.index);
							break;
					case halt:
							s.index = encode_halt(s.index);
//							printf("found halt instruction\n");
							break;
					case semi: // this is the end of the line so one line of micro instrucion should be done.
//						printf("Found semi colon \n");
						source_def = target_def = FALSE; // Clear flags
						if (s.mstate != done) // keep the done state
							s.mstate = inst;
						break;
					default:
							s = encode_source_t(s);
						break;

				} 
		// need to add error processing here 
		s.index++;
		}	
	return(s);
}
/* If get here we have a valid instruction and address so we can place these items 
in the rom image ready to be dumped
*/
struct parser_var build_instr(struct parser_var s)
{
	int flag_bit;
	int address1, address;
	flag_bit = (flag_def == TRUE) ?  1<<12:0;
	address = (current_micro_flag_address<<8)+current_instruction +  flag_bit; 
	address1 = (current_micro_address<<8)+current_instruction +  flag_bit; 

	if(tok_line[0] == 0 || tok_line[0] == semi){ // line contains no code so reset and continue to scan op code
		s.mstate = scan;			
	} else { //if we get here we have some code to be encoded
		if (flag_def)
		{
			printf(":%04x: ",address );
			current_micro_flag_address++;
			control_rom[address] = en_inst.instructionb;
			flag_def = FALSE;
		} else
		{
			printf(":%04x: ",address1 );
			control_rom[address1] = en_inst.instructionb;
			current_micro_address++;
		}
		for( int i=0; i < 32 ; i++)
				{
//				printf("%d ",instruction_word[31-i]);
				instruction_word[31-i] =0; // clear ready for next code
				}
		printf(" :%08x:",en_inst.instructionb);
 //		printf("%d",sizeof(int));		
		en_inst.instructionb =0;
	}
//	printf("\n");
	s.mstate = op;
	return(s);
}
// This routine will build the code for the mirco instruction in format source -> destination 
struct source_reg { int op; int bitp; int address_mode; };
// Table below is in the form register code, enable mnemonic, true if has an address mode 

struct source_reg source_reg_tab[] = {A,EN_A,FALSE,\
									  B,EN_B,FALSE,\
									  C,EN_C,FALSE,\
									  D,EN_D,FALSE,\
									  acum,0,FALSE,\
									  _ram,EN_RAM,TRUE,\
									  _sp,EN_SP,TRUE,\
									  _mar,EN_X,TRUE,\
									  _pc,R_PC,TRUE,\
									  _Y,EN_Y,TRUE,\
	                                  _F,EN_Flags,FALSE,\
									  H,EN_H,FALSE,\
	                                  L,EN_L,FALSE,\
	                                  SC,0,FALSE,\
									  SD,0,FALSE,\
							          0,0,0 }; // end of table
struct parser_var encode_source_t(struct parser_var s)
{

	int i=0;
	struct p_state p, *pp;
	pp = &p;
//	print_tok_line(tok_line);
//	printf("Currently processing %s\n",menomics[tok_line[s.index]-1]);

	while(source_reg_tab[i].op !=0)
	{
		if(source_reg_tab[i].op == tok_line[s.index]) //found valid source target
		{
			if(source_def)
			{
				printf("In line %d syntax error source already defined\n",line_cnt);
				s.mstate = scan; //abort processing
				return (s);
			} else {
				source_def = TRUE; 
			}
			break;
		}
		i++;
	}
	if(source_reg_tab[i].op == 0) // no valid source found
	{
		printf("In line %d syntax error no valid source found\n",line_cnt);
		s.mstate = scan; //abort processing
		return (s);
	}
	instruction_word[REG_CODES] = source_reg_tab[i].bitp;
	en_inst.instruction.Sreg_code = source_reg_tab[i].bitp;
	s.index++; // point to next token
	if (source_reg_tab[i].address_mode) // if true we have to look address info.
		{
			
		p.s = s;
 		process_brackets(pp, lbr);
		s = p.s;
		if( p.tok == -1 ) // we have error
			{
			s.mstate = scan; //abort processing
			return (s);	
			}
//		printf("Currently processing %s\n",menomics[p.tok-1]);
		if (!get_address_s(p.tok))
			{
				printf("In line %d invalid address for source reg\n",line_cnt);
				s.mstate = scan; //abort processing
				return (s);
			}
	
		}
// If we arrive here source is OK and built into the instruction word
		if(tok_line[s.index] != point )
			{
			printf("In line %d syntax error missing '->'\n",line_cnt);
			s.mstate = scan; //abort processing
			return (s);
			}
		
// if we get here we are looking for the write target 
	s.index++;
	switch(tok_line[s.index])
	{
			// the first group a simple select line pair 
			case A: // The A Reg is Target
				instruction_word[WA] = 1;
				en_inst.instruction.Dreg_code =WA;

				break;
			case B: // The B Reg is Target
				instruction_word[WB] = 1;
				en_inst.instruction.Dreg_code =WB;

				break;
				
			case C: // The C Reg is Target
				instruction_word[WC] = 1;
				en_inst.instruction.Dreg_code =WC;
				break;

			case D: // The D Reg is Target
				instruction_word[WD] = 1;
				en_inst.instruction.Dreg_code =WD;
				break;
			case H: // The H Reg is Target
				instruction_word[WC] = 1;
				en_inst.instruction.Dreg_code =WH;
				break;

			case L: // The L Reg is Target
				instruction_word[WD] = 1;
				en_inst.instruction.Dreg_code =WL;
				break;

			case T: // no longer valid remove at some point and fix micro code
				instruction_word[Wtemp] = 1;
				en_inst.instruction.Dreg_code =5; //fixme add correct codes later
				break;
			case instr:
				instruction_word[LDI] = 1;
				en_inst.instruction.ldinst =1;
				break;
			case _F: // flag register we
				en_inst.instruction.Dreg_code = 11; 
				break;
			case acum: // this just to keep syntax corrrect the ALU instruction activates ALU to carry out action. 
				break;
// this completes the simple instructions;

			case _ram:
				s.index++; //skip past code
				p.s = s;
 				process_brackets(pp, lbr);
				s = p.s;
				if( p.tok == -1 ) // we have error
					{
					s.mstate = scan; //abort processing
					return (s);	
					}
					instruction_word[W_SEL_A]= W_RAM;
					en_inst.instruction.Dreg_code = 15;
					
				switch(p.tok) // now select address to use
					{
					case _pc:
						instruction_word[SEL_AD] = A_PC; // default state
						en_inst.instruction.ad_mast =A_PC;
						break;
					case _mar: //Now X reg
						en_inst.instruction.ad_mast =A_MAR;
						instruction_word[SEL_AD] = A_MAR; // default state
						break;
					case _Y: //The new Y reg
						en_inst.instruction.ad_mast =A_Y;
						instruction_word[SEL_AD] = A_Y; // default state
						break;

					case _sp:
						en_inst.instruction.ad_mast =A_SP;
						instruction_word[SEL_AD] = A_SP; // default state
						break;
					case _M: // this generates 
						en_inst.instruction.ad_mast = A_M;
						en_inst.instruction.__sel_msb = 1;
						en_inst.instruction.__sel_lsb =0;
						break;		
					default:  // if here syntax error
						printf("In line %d syntax errorno valid address for ram\n",line_cnt);
						s.mstate = scan; //abort processing
						return (s);	
					}
				
				break;
			case _pc:
					instruction_word[W_SEL_A] = LATCH_PC;
//					en_inst.instruction.AD_Latch = 0; Not used
					en_inst.instruction.Dreg_code = 7; // write PC
					s.index++; 
					p.s = s;
 					process_brackets(pp, lbr);
					s = p.s;
					if( p.tok == -1 ) // we have error
						{
						s.mstate = scan; //abort processing
						return (s);	
						}
				if(p.tok == _lsb)
					{
					instruction_word[EN_LD_LSB] =1;
					en_inst.instruction.__sel_msb = 0;
				    en_inst.instruction.__sel_lsb = 1;
					}
 				else if(p.tok == _msb)
					{
					instruction_word[EN_LDPC_MSB] =1;
					en_inst.instruction.__sel_lsb = 0; //Latch and enable AD bus
					en_inst.instruction.__sel_msb = 1;
					}
				else
					{
					printf("In line %d syntax error not MSB or LSB\n",line_cnt);
					s.mstate = scan; //abort processing
					return (s);
					}
					break;
			case _sp:
			case _mar:
			case _Y:
					if(tok_line[s.index] == _sp)
						{
						en_inst.instruction.Dreg_code = 8; // write SP
//						en_inst.instruction.AD_Latch =0; //not used
						instruction_word[W_SEL_A] = A_SP;
						}
					else if(tok_line[s.index] == _mar)
						{
						en_inst.instruction.Dreg_code = 9; // write X was MAR
//						en_inst.instruction.AD_Latch =0; //not used
						}
					else {
						en_inst.instruction.Dreg_code = 10; // 
//						en_inst.instruction.AD_Latch =0; //Not used
						}
					s.index++;
					p.s = s;
 					process_brackets(pp, lbr);
					s = p.s;
					if( p.tok == -1 ) // we have error
						{
						s.mstate = scan; //abort processing
						return (s);	
						}

				if(p.tok == _lsb)
					{
//					en_inst.instruction.sel_address = 0; // switch back PC active 
					en_inst.instruction.__sel_msb =0;
				    en_inst.instruction.__sel_lsb = 1;
					instruction_word[EN_LD_LSB] =1;
					}
 				else if(p.tok == _msb)
					{
					en_inst.instruction.__sel_msb =1;
					en_inst.instruction.__sel_lsb =0;
					//syntax valid
					}
				else
					{
					printf("In line %d syntax error not MSB or LSB\n",line_cnt);
					s.mstate = scan; //abort processing
					return (s);
					}		
				
	}
	return s;
}
// This routine returns the correct source address bits
//
int get_address_s(int tok)
{
	int ret=FALSE;
	switch(tok)
	{
		case _pc:
			instruction_word[SEL_AD] = A_PC;
			en_inst.instruction.ad_mast = A_PC;
			ret = TRUE;
			break;
		case _sp:
			instruction_word[SEL_AD] = A_SP;
			en_inst.instruction.ad_mast = A_SP;
			ret = TRUE;
			break;
		case _mar:
			instruction_word[SEL_AD] = A_MAR;
			en_inst.instruction.ad_mast = A_MAR;
			ret = TRUE;
			break;
		case _Y:
			en_inst.instruction.ad_mast = A_Y;
			ret = TRUE;
			break;
		case _M:
//			en_inst.instruction.sel_address = A_M;
			en_inst.instruction.__sel_msb = 1;
			en_inst.instruction.__sel_lsb =0;
			ret = TRUE;
			break;
		case _lsb: // we asume the 16 bit has been saved prior to read
//			en_inst.instruction.sel_address	 = 1; // Anything < 0 will turn off ADbus
			en_inst.instruction.__sel_msb =0;
			en_inst.instruction.__sel_lsb = 1;
			ret = TRUE;
			break;
		case _msb: // this must be a 16 bit register read
// 			en_inst.instruction.sel_address	 = 1; // Anything < 0 will turn off ADbus
			en_inst.instruction.__sel_msb = 1;
			en_inst.instruction.__sel_lsb = 0;
			ret = TRUE;
			break;
	}
	return(ret);
}
// this routine will process all brackets to keep all the code in one place
// It is call with s.index pointing to the start of bracket and returns the op_code or -1 if there was an error
// in processing   
int process_brackets(struct p_state *pp, int tok)
{
	// value passed is the left side we are looking for
			if (tok_line[pp->s.index] != tok)
				{
				printf("In line %d syntax error missing '%s'\n",line_cnt,menomics[tok_line[pp->s.index]-1]);
				pp->s.mstate = scan; //abort processing
				pp->tok = -1; 
				} 
			else if(tok_line[pp->s.index+2] != tok+1) // these always defined as pairs in L + R format
				{ 
				printf("In line %d syntax error missing '%s'\n",line_cnt,menomics[tok_line[pp->s.index]-1]);
				pp->s.mstate = scan; //abort processing
				pp->tok = -1; 
				} 
			else
				{ // Syntax correct retun with correct 
				pp->tok = tok_line[pp->s.index+1];
				}
			pp->s.index = pp->s.index +3; // point to next token 
	return(tok);
}
// This function now places the DB onto the ALU B buss
int encode_swap(int index)
{
	instruction_word[TMP_SEL]=1; // Enable temp reg to replace B
	en_inst.instruction.DBtoALU = 1;
	return index;
}
// This function now places the DC onto the ALU A B bus
int encode_swapAD(int index)
{
	instruction_word[TMP_SEL]=1; // Enable temp reg to replace B
	en_inst.instruction._AorD = 1;
	return index;
}
int encode_save(int index) //Hacked for now 
{
	en_inst.instruction.W16 = 1; // Capture select Address
	switch (tok_line[index+2])
	{
		case _sp:
			en_inst.instruction.ad_mast =A_SP;
			break;
		case _pc:
			en_inst.instruction.ad_mast =A_PC;
			break;
		case _mar:
			en_inst.instruction.ad_mast =A_MAR;
			break;
		case _Y:
			en_inst.instruction.ad_mast =A_Y;
			break;
	}
	return index+3;
}
// dump hex file
void dumpHex(void)
{
   FILE *fp;
   int cnt = 1,cnting = FALSE;
   fp = fopen("a.out" , "w");
   if(fp == NULL) {
      perror("Error output opening file");
	}
	fprintf(fp,"v2.0 raw\n");
		for ( int i=0; i < 32768; i++)
			{
			if( control_rom[i] == control_rom[i+1]) // we have a run
				{ 
				cnt++;
				} else
				{
					if(cnt == 1)
						fprintf(fp,"%x\n",control_rom[i]);
					else 
						fprintf(fp,"%d*%x\n",cnt,control_rom[i]);
					
					cnt =1;
				}
			}
	fclose(fp);
}
// Load first 256 with fetch instruction 
void initHex(void)
{
		for( int i=0; i < 256; i++)
			control_rom[i] = FETCH;

}
