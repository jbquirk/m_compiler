// This is mirco code for my designed CPU
//
// reorg into groups so easier to see and add instructions.
//
// This is slowly moving towards a complete set of instructions
// Not all possible combinations will be able to use as I am running out instruction space.
// I will the flow control section just for this control only has two instructions 
//  
// 00 instructions Control?
//
op: 0x00 ;//HLT 1 cpu halts cant be restarted 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: halt,jmp0; //cpu stops
*:end;
op: 0x01 ;//NOP 1 does nothing
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: jmp0; //cpu skips to next instruction
*:end;
op: 0x02; //POP_H 1 pop 8 bit a reg 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp) ;
*: ram[sp]->REGH,jmp0; //pop a
*: end ;
op: 0x03; //POP_L 1 pop 8 bit a reg 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp) ;
*: ram[sp]->REGL,jmp0; //pop a
*: end ;
op: 0x04; //MOVA_L 1 Move A to L no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->REGL,jmp0;
*:end;
op: 0x05; //MOVA_H 1 Move A to H no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->REGH,jmp0;
*:end;
op: 0x06; //MOVL_A 1 Move L to A no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->REGA,jmp0;
*:end;
op: 0x07; //MOVH_A 1 Move H to A no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->REGA,jmp0;
*:end;
op: 0x08; //MOVB_H 1 Move B to H no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->REGH,jmp0;
*:end;
op: 0x09; //MOVB_L 1 Move B to L no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->REGL,jmp0;
*:end;
op: 0x0a; //MOVH_B 1 Move H to B no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->REGB,jmp0;
*:end;
op: 0x0b; //MOVL_B 1 Move L to B no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->REGB,jmp0;
*:end ;
op: 0x0c; //MOV_HL_DA 1 Move HL to DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->REGA, ; 
*: REGH->REGD,jmp0 ;
*:end ;
op: 0x0d; //MOV_HL_CB 1 Move HL to CB
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->REGB, ; 
*: REGH->REGC,jmp0 ;
*:end ;
op: 0x0e; //PUSHALL 1 push all registers to stack except sp and pc
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: FLAGS->ram[sp],dec(sp); //push Flags
*: REGD->ram[sp],dec(sp); //Push D
*: REGA->ram[sp],dec(sp); //push A
*: REGC->ram[sp],dec(sp); //Push C
*: REGB->ram[sp],dec(sp); //push B
*: REGH->ram[sp],dec(sp); //Push L
*: REGL->ram[sp],dec(sp); //push H
*: mar[msb]->ram[sp],dec(sp); //Push X LSB
*: mar[lsb]->ram[sp],dec(sp); //Push X MSB
*: Y[msb]->ram[sp],dec(sp); //Push Y LSB
*: Y[lsb]->ram[sp],dec(sp),jmp0; //Push Y MSB
*: end ;
op: 0x0f; //POPALL 1 pops all registers from stack except sp and pc
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp) ;
*: ram[sp]->Y[lsb],inc(sp); //Pop Y LSB
*: ram[sp]->Y[msb],inc(sp); //Pop Y MSB
*: ram[sp]->mar[lsb],inc(sp); //Pop X LSB
*: ram[sp]->mar[msb],inc(sp); //POP X MSB
*: ram[sp]->REGL,inc(sp); //pop L
*: ram[sp]->REGH,inc(sp); //pop H
*: ram[sp]->REGB,inc(sp); //POP B
*: ram[sp]->REGC,inc(sp); //Pop C
*: ram[sp]->REGA,inc(sp); //pop A
*: ram[sp]->REGD,inc(sp); //Pop D
*: ram[sp]->FLAGS,jmp0; //pop Flags
*: end ;
//
// 10 Instructions currently all increment and decrement instructions Note only AD can be increament and Decremented now
//    Note the redesign now only has two acumulators A and D The X and Y have hardware inc and decreament 
op: 0x10; //DEC_A 1 Decrement A flags set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(dec),jmp0; // A is alu target
*:end;
op: 0x11; //DEC_D 1 Decrement B flags set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(dec),jmp0,swapAD; 
*:end;
op: 0x12; //INC_A 1 Decrement A flags set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(inc),jmp0;
*:end;
op: 0x13; //INC_D 1 Decrement D flags set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(inc),jmp0,swapAD;
*:end;
op: 0x14; //DEC_X 1 decreament 16 bit X reg flags not set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: dec(mar),jmp0;
*:end;
op: 0x15; //DEC_Y 1 decreament 16 bit Y reg flags not set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: dec(Y),jmp0;
*:end;
op: 0x16; //INC_X 1 Increament 16 bit X reg flags not set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(mar),jmp0;
*:end;
op: 0x17; //INC_Y 1 Increament 16 bit Y reg flags not set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(Y),jmp0;
*:end;
op: 0x18 ; //ADCI_DA 3 Add 16 bit mem to DA with carry 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(adc),inc(pc),swapBT; //LSB
*: ram[pc]->acum,alu(adc),jmp0,inc(pc),swapBT,swapAD; //MSB
*: end;
op: 0x19 ; //ADC_DA_CB 1 Add CB to DA with carry store result in DA 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(adc),; 
*: ram[pc]->acum,alu(adc),jmp0,swapAD;  
*:end;
op: 0x1a ; //ADD_A_L 1 Add A to reg L store result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->acum,alu(add),jmp0,swapBT; 
*:end;
op: 0x1b ; //ADD_A_H 1 Add A to reg H store result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->acum,alu(add),jmp0,swapBT; 
*:end;
op: 0x1c ; //ADC_A_L 1 Add A to reg L store result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->acum,alu(add),jmp0,swapBT; 
*:end;
op: 0x1d ; //ADC_A_H 1 Add A to reg H store result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->acum,alu(add),jmp0,swapBT; 
*:end;
op: 0x1e ; //ADC_D_C 1 Add C to D 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(adc),jmp0,swapAD; 
*:end;
op: 0x1f; //ST_L_X 1 Write L to mem with X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->ram[mar],jmp0;
*: end;
//
// Hex 20 instructions logic operations
//
op: 0x20 ; //ANDI_A 2 And A imediate from mem
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(and),jmp0,inc(pc),swapBT; 
*:end;
op: 0x21 ; //ANDI_D 2 And B imediate from mem
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(and),inc(pc),jmp0,swapAD,swapBT; 
*:end;
op: 0x22 ; //ANDA_B 1 A and B result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(and),jmp0 ; //B reg on B buss already 
*:end;
op: 0x23 ; //ANDD_C 1 D and C result in D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(and),jmp0,swapAD  ;
*:end;
op: 0x24 ; //ANDA_H 1 A and H result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->acum,alu(and),jmp0,swapBT  ; 
*:end;
op: 0x25 ; //ANDA_L 1 A and L result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->acum,alu(and),jmp0,swapBT  ; 
*:end;
op: 0x26 ; //ANDDA_CB 1 AD and CB result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(and) ; 
*: alu(and),jmp0,swapAD  ;
*:end;
op: 0x27 ;//SLL_A 1 shift left A by value in B result in A carry flag uneffected.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(sll),jmp0; 
*:end;
op: 0x28 ;//SLR_A 1 shift right A by value in B result in A carry flag effected.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(slr),jmp0; 
*:end;
op: 0x29 ;//SLL_D 1 shift left D result in D carry flag uneffected.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(sll),jmp0,swapAD; 
*:end;
op: 0x2a ;//SLR_D 1 shift right D result in D carry flag effected.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(slr),jmp0,swapAD; 
*:end;
op: 0x2b ; //ORDA_CB 1 AD and CB result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(or) ; 
*: alu(or),jmp0,swapAD  ;
*:end;
op: 0x2c ; //ANDI_DA 3 AD with MEM result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(and), swapBT,inc(pc); 
*: alu(and),jmp0,swapAD,swapBT  ;
*:end;
op: 0x2d ; //ORI_DA 3 AD with MEM result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(or), swapBT,inc(pc); 
*: alu(or),jmp0,swapAD,swapBT  ;
*:end;
op: 0x2e ; //ORA_H 1 A or H result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->acum,alu(or),jmp0,swapBT  ; 
*:end;
op: 0x2f ; //ORA_L 1 A or L result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->acum,alu(or),jmp0,swapBT  ; 
*:end;
//
// Hex 30 instructions load group
//
//
// Load imediate instructions
//
op: 0x30 ; //LDI_A 2 load A immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGA,inc(pc),jmp0  ;
*: end;
op: 0x31 ; //LDI_B 2 load B immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGB,inc(pc),jmp0  ;
*: end;
op: 0x32 ; //LDI_C 2 load C immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGC,inc(pc),jmp0  ;
*: end;
op: 0x33 ; //LDI_D 2 load D immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGD,inc(pc),jmp0  ;
*: end;
op: 0x34; //LD_C_X 1 Load C from mem with MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGC,jmp0;
*: end;
op: 0x35; //LD_D_X 1 Load D from mem with MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGD,jmp0;
*: end;
op: 0x36; //LD_L_X 1 Load L from mem with MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGL,jmp0;
*: end;
op: 0x37 ;//LDI_SP 3 Write sp immediate
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->sp[lsb],inc(pc) ;//Write lsb to pc counter
*: ram[pc]->sp[msb],inc(pc),jmp0 ;//WritePC counter and end
*: end ;
op: 0x38; //LDI_X 3 load X imeadiatly from mem
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->mar[lsb],inc(pc);
*: ram[pc]->mar[msb],inc(pc),jmp0;
*: end;
op: 0x39; //LDI_Y 3 load Y imeadiate
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->Y[lsb],inc(pc);
*: ram[pc]->Y[msb], inc(pc),jmp0;  
*: end;
op: 0x3a; //LDX_(X) 1 load mem pointed to by X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->mar[lsb],inc(mar);
*: ram[mar]->mar[msb],jmp0;
*: end;
op: 0x3b; //LDY_(X) 1 load mem pointed to by X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->Y[lsb],inc(mar);
*: ram[mar]->Y[msb],inc(mar),jmp0; 
*: end;
op: 0x3c; //LDX_(Y) 1 load X pointer to by Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->mar[lsb],inc(Y);
*: ram[Y]->mar[msb],inc(Y),jmp0;
*: end;
op: 0x3d; //LDY_(Y) 1 load Y pointed to by Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->Y[lsb],inc(Y);
*: ram[Y]->Y[msb],jmp0;  
*: end;
op: 0x3e ; //LDI_H 2 load H immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGH,inc(pc),jmp0  ;
*: end;
op: 0x3f ; //LDI_L 2 load L immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGL,inc(pc),jmp0  ;
*: end;
//
// hex 40 math instructions
//
op: 0x40 ; //ADDI_DA 3 Add 16 bit mem to DA 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(add),inc(pc),swapBT; //LSB
*: ram[pc]->acum,alu(adc),jmp0,inc(pc),swapBT,swapAD; //MSB
*: end;
op: 0x41 ; //ADDI_A 2 Add mem location to A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(add),jmp0,inc(pc),swapBT; 
*:end;
op: 0x42 ; //ADDI_D 2 Add D imediate from mem
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(add),jmp0,inc(pc),swapBT,swapAD; 
*:end;
op: 0x43 ; //ADD_A_B 1 Add A to reg B store result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(add),jmp0; 
*:end;
op: 0x44 ; //ADD_D_C 1 Add C to D 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(and),jmp0,swapAD; 
*:end;
op: 0x45 ; //ADD_DA_CB 1 Add CB to DA store result in DA 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(add),jmp0; 
*: ram[pc]->acum,alu(adc),jmp0,swapAD;  
*:end;
op: 0x46 ; //SUBI_A 2 A - (mem location) result in A 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(sub),jmp0,inc(pc),swapBT;  
*:end;
op: 0x47 ;//SUBI_D 2 D - (mem location) result in D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*:  ram[pc]->acum,alu(sub),jmp0,inc(pc),swapBT,swapAD;  
*:end;
op: 0x48 ; //SUB_A_B 1 A - B result in A 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(sub),jmp0;  
*:end;
op: 0x49 ;//SUB_D_C 1 D - C result in D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(sub),jmp0,swapAD;  
*:end;
op: 0x4a ;//CMPI_A 2 A is compared to value in memeory result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(cmp),inc(pc),jmp0,swapBT;  
*:end;
op: 0x4b ;//CMP_A_B 1 A is compared to value in B result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(cmp),jmp0;  
*:end;
op: 0x4c ;//CMP_D_C 1  D is compared to C result in D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(cmp),jmp0,swapAD;  
*:end;
op: 0x4d ; //ADCI_A 2 Add with carry mem location to A store in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(adc),jmp0,inc(pc),swapBT; 
*:end;
op: 0x4e ; //ADCI_D 2 Add with carry D imediate from mem store in D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(adc),jmp0,inc(pc),swapBT,swapAD; 
*:end;
op: 0x4f ; //ADC_A_B 1 Add with carry A to B result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(adc),jmp0; 
*:end;
//
// Hex 50 instructions Register to register to register moves.
//
op: 0x50; //MOVA_B 1 Move A to B no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->REGB,jmp0;
*:end;
op: 0x51; //MOVA_C 1 Move A to C no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->REGC,jmp0;
*:end;
op: 0x52; //MOVA_D 1 Move A to D no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->REGD,jmp0;
*:end;
op: 0x53; //MOVB_A 1 Move B to A no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->REGA,jmp0;
*:end;
op: 0x54; //MOVB_C 1 Move B to C no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->REGC,jmp0;
*:end;
op: 0x55; //MOVB_D 1 Move B to D no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->REGD,jmp0;
*:end;
op: 0x56; //MOVC_A 1 Move C to A no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGC->REGA,jmp0;
*:end;
op: 0x57; //MOVC_B 1 Move C to B no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGC->REGB,jmp0;
*:end;
op: 0x58; //MOVC_D 1 Move C to D no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGC->REGD,jmp0;
*:end;
op: 0x59; //MOVD_A 1 Move D to A no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGD->REGA,jmp0;
*:end;
op: 0x5a; //MOVD_B 1 Move D to B no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGD->REGB,jmp0;
*:end;
op: 0x5b; //MOVD_C 1 Move D to C no flags effected
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGD->REGC,jmp0;
*:end;
op: 0x5c; //MOV_SP_X 1 Move stack pointer to X reg
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: sp[lsb]->mar[lsb], ; // this is two cycles I suspect hardware can do it in one.
*: sp[msb]->mar[msb],jmp0 ;
*:end;
op: 0x5d; //MOV_SP_Y 1 Move stack pointer to Y reg
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: sp[lsb]->Y[lsb], ; // this is two cycles I suspect hardware can do it in one.
*: sp[msb]->Y[msb],jmp0 ;
*:end;
op: 0x5e; //MOV_SP_CB 1 Move stack pointer to BC reg
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: sp[lsb]->REGB, ; 
*: sp[msb]->REGC,jmp0 ;
*:end;
op: 0x5F; //MOV_SP_HL 1 Move stack pointer to hl reg
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: sp[lsb]->REGL, ; 
*: sp[msb]->REGH,jmp0 ;
*:end;

//
//
//
// Hex 60 instruction store group
//
op: 0x60; //ST_A_X 1 Write A to mem with MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->ram[mar],jmp0;
*: end;
op: 0x61; //ST_A_Y 1 Write A to mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->ram[Y],jmp0;
*: end;
op: 0x62; //ST_B_X 1 Write B to mem with X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->ram[mar],jmp0;
*: end;
op: 0x63; //ST_B_Y 1 Write B to mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->ram[Y],jmp0;
*: end;
op: 0x64; //ST_C_Y 1 Write C to mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGC->ram[Y],jmp0;
*: end;
op: 0x65; //ST_C_X 1 Write C to mem with X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGC->ram[mar],jmp0;
*: end;
op: 0x66; //ST_D_Y 1 Write D to mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGD->ram[Y],jmp0;
*: end;
op: 0x67; //ST_D_X 1 Write D to mem with X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGD->ram[mar],jmp0;
*: end;
op: 0x68; //LD_DA_+Y 1 Load DA from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGA,inc(Y); lsb
*: ram[Y]->REGD,inc(Y),jmp0; msb
*: end;
op: 0x69; //LD_DA_+X 1 Load DA from mem pointed by Y and inc Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGA,inc(mar);
*: ram[mar]->REGD,inc(mar),jmp0;
*: end;
op: 0x6A; //LD_B_X 1 Load B from mem with MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGB,jmp0;
*: end;
op: 0x6b; //LD_A_X 1 Load A from mem with MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGA,jmp0;
*: end;
op: 0x6c; //LD_A_+X 1 Load A from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGA,inc(mar),jmp0;
*: end;
op: 0x6d; //LD_A_+Y 1 Load A from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGA,inc(Y),jmp0;
*: end;
op: 0x6e; //ST_A_+X 1 Write A to mem with MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->ram[mar],inc(mar),jmp0;
*: end;
op: 0x6f; //ST_A_+Y 1 Write A to mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->ram[Y],inc(Y),jmp0;
*: end;

//
// Hex 70 instructions Push/pop group
//
op: 0x70; //PUSH_A 1 push A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->ram[sp], dec(sp),jmp0; //push A
*: end ;
op: 0x71; //PUSH_B 1 push 8 bit B
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->ram[sp], dec(sp),jmp0; //push B
*: end ;
op: 0x72; //PUSH_C 1 push 8 bit C
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGC->ram[sp], dec(sp),jmp0; //push C
*: end ;
op: 0x73; //PUSH_D 1 push 8 bit B
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGD->ram[sp], dec(sp),jmp0; //push D
*: end ;
op: 0x74; //PUSH_F 1 push flags
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: FLAGS->ram[sp], dec(sp),jmp0; //push Flags
*: end ;
op: 0x75; //PUSH_X 1 Push the X reg
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: mar[msb]->ram[sp],dec(sp) ; //note in this case its the sp
*: mar[lsb]->ram[sp],dec(sp),jmp0; 
*: end;
op: 0x76; //PUSH_Y 1 push the Y reg
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: Y[msb]->ram[sp],dec(sp) ; //note in this case its the sp
*: Y[lsb]->ram[sp],dec(sp),jmp0; 
*: end;
op: 0x77; //POP_F 1 pop flags
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp) ;
*: ram[sp]->FLAGS,jmp0; 
*: end;
op: 0x78; //POP_A 1 pop 8 bit a reg 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp) ;
*: ram[sp]->REGA,jmp0; //pop a
*: end ;
op: 0x79; //POP_B 1 pop 8 bit a reg 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp) ;
*: ram[sp]->REGB,jmp0; //pop a
*: end ;
op: 0x7A; //POP_C 1 pop 8 bit a reg 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp) ;
*: ram[sp]->REGC,jmp0; //pop a
*: end ;
op: 0x7b; //POP_Y Pops Y 16 bit value
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp);
*: ram[sp]->Y[lsb],inc(sp) ; 
*: ram[sp]->Y[msb],jmp0 ;  
*: end;
op: 0x7C; //POP_X 1 pops X 16 bit value
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp);
*: ram[sp]->mar[lsb],inc(sp) ; 
*: ram[sp]->mar[msb],jmp0;
*: end;
op: 0x7D; //POP_D 1 pop 8 bit a reg 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp) ;
*: ram[sp]->REGD,jmp0; //pop a
*: end ;
op: 0x7E; //PUSH_H 1 push H
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->ram[sp], dec(sp),jmp0; //push A
*: end ;
op: 0x7F; //PUSH_L 1 push 8 bit L
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->ram[sp], dec(sp),jmp0; //push B
*: end ;
//
// Hex 80 instructions Flow control
//
op: 0x80; //CALL 3 Unconditional note PC and flags is saved
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
*: FLAGS->ram[sp],dec(sp);
*: pc[msb]->ram[sp],dec(sp);
*: pc[lsb]->ram[sp],dec(sp);
*: ram[pc]->pc[msb],jmp0  ;//WritePC counter Address n-1 was latched
*: end;
op: 0x81; //JMP 3 Unconditional Jump instruction
// Jump instruction
//
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
*: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
*: end ;
op: 0x82 ; //JNEQ 3 Jump if equal than flag set 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
=: inc(pc);
!=: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
=: jmp0,inc(pc);
!=: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
*: end;
// Next set is the code for jmp zero
op: 0x83 ; //JPZ 3 Jump if zero flag set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
Z: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
!Z: inc(pc);
Z: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
!Z:jmp0,inc(pc) ; 
*: end;
op: 0x84; //J(DA) 1 Unconditional Jump instruction with value in DA
// Jump instruction
//
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->pc[lsb], ;//Write lsb to pc counter
*: REGD->pc[msb],jmp0 ;//WritePC counter and end
*: end ;
op: 0x85 ; //JNZ 3 Jump if zero flag is not set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
Z: inc(pc);
!Z: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
Z: jmp0,inc(pc);
!Z: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
*: end;
op: 0x86 ; //JLT 3 Jump if Less than flag set 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
LT: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
!LT: inc(pc);
LT: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
!LT: jmp0,inc(pc);
*: end;
op: 0x87 ; //JGT 3 Jump if Greater than flag set
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch 
GT: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
!GT: inc(pc);
GT: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
!GT: jmp0,inc(pc);
*: end;
op: 0x88 ; //JEQ 3 Jump if equal than flag set 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
=: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
!=: inc(pc);
=: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
!=: jmp0,inc(pc);
*: end;
op: 0x89 ; //JPC 3 Jump if carry than flag set 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
C: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
!C: inc(pc);
C: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
!C: jmp0,inc(pc);
*: end;
//
op: 0x8A ; //JNEG 3 Jump if negitive flag set 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
neg: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
!neg: inc(pc);
neg: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
!neg: jmp0,inc(pc);
*: end;
op: 0x8b ; //JPOS 3 Jump if negitive flag set 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
neg: inc(pc);
!neg: ram[pc]->pc[lsb],inc(pc) ;//Write lsb to pc counter
neg: jmp0,inc(pc);
!neg: ram[pc]->pc[msb],jmp0 ;//WritePC counter and end
*: end;
op: 0x8c; //C(DA) 1 with value in DA Unconditional note PC and flags is saved
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: FLAGS->ram[sp],dec(sp);
*: pc[msb]->ram[sp],dec(sp);
*: pc[lsb]->ram[sp],dec(sp);
*: REGA->pc[lsb], ;//Write lsb to pc counter
*: REGD->pc[msb],jmp0  ;//WritePC counter Address n-1 was latched
*: end;
op: 0x8f; //RET 1 Pops pc and restores flags
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: inc(sp);
*: ram[sp]->pc[lsb],inc(sp) ; 
*: ram[sp]->pc[msb],inc(sp);
*: ram[sp]->FLAGS, ;
*: inc(pc),jmp0 ; //fix up PC 
*: end;
//
// Hex 90 spare
//
op: 0x90 ; //XOR_DA_CB 1 XOR DA to reg CB store result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(xor),; 
*: alu(xor),jmp0,swapAD;
*:end;
op: 0x91 ; //NOT_DA 1 NOT DA reg store result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(nota), ;
*: alu(nota),jmp0,swapAD; 
*:end;
op: 0x92 ; //XOR_A_L 1 A and L result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->acum,alu(xor),jmp0,swapBT  ; 
*:end;
op: 0x93 ; //XOR_A_B 1 XOR A to reg B store result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(xor),jmp0; 
*:end;
op: 0x94 ; //XORI_A 2 XOR A with memeory 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(xor),jmp0,inc(pc),swapBT;
*:end;
op: 0x95 ; //ORI_A 2 OR mem location to A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(or),jmp0,inc(pc),swapBT; 
*:end;
op: 0x96 ; //OR_A_B 1 OR A with B
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(or),jmp0; 
*:end;
op: 0x97 ; //NOT_A 1 NOT A result in A 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(nota),jmp0; 
*:end;
op: 0x98 ; //SET_A 1 set A set A to all ones.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(set),jmp0; 
*:end;
op: 0x99 ; //CLR_A 1 clr A set A to all zeros.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(clr),jmp0; 
*:end;
op: 0x9a ; //SET_D 1 set A set A to all ones.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(set),swapAD,jmp0; 
*:end;
op: 0x9b ; //CLR_D 1 clr A set A to all zeros.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(clr),swapAD,jmp0; 
*:end;
op: 0x9c ; //SET_DA 1 set DA set DA to all ones.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(set),swapAD,; 
*: alu(set),jmp0; 
*:end;
op: 0x9d ; //CLR_DA 1 clr DA set DA to all zeros.
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(clr),swapAD,; 
*: alu(clr),jmp0; 
*:end;
op: 0x9e ; //ORI_D 2 OR mem location to D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(or),jmp0,inc(pc),swapBT,swapAD; 
*:end;
op: 0x9f ; //OR_D_C 1 OR D with C result in D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(or),jmp0,swapAD; 
*:end;
//
// Hex A0 spare
//
op: 0xA0 ; //XOR_A_H 1 A xor H result in A
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->acum,alu(xor),jmp0,swapBT  ; 
*:end;
op: 0xa1 ; //XORI_DA 3 AD with MEM result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(xor), swapBT,inc(pc); 
*: alu(xor),jmp0,swapAD,swapBT  ;
*:end;
op: 0xa3 ; //SBCI_A 2 A - (mem location) result in A with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(sbc),jmp0,inc(pc),swapBT;  
*:end;
op: 0xa4 ;//SBCI_D 2 D - (mem location) result in D with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*:  ram[pc]->acum,alu(sbc),jmp0,inc(pc),swapBT,swapAD;  
*:end;
op: 0xa5 ; //SBC_A_B 1 A - B result in A with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(sbc),jmp0;  
*:end;
op: 0xa6 ;//SBC_D_C 1 D - C result in D with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(sbc),jmp0,swapAD;  
*:end;
op: 0xa7 ; //SBC_A_H 1 A - H result in A with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->acum,alu(sbc),jmp0,swapBT;  
*:end;
op: 0xa8 ;//SBC_A_L 1 A - L result in A with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->acum,alu(sbc),jmp0,swapBT;  
*:end;
op: 0xa9 ; //SUB_A_H 1 A - H result in A with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->acum,alu(sub),jmp0,swapBT;  
*:end;
op: 0xaa ;//SUB_A_L 1 A - L result in A with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->acum,alu(sub),jmp0,swapBT;  
*:end;
op: 0xab ;//SUBI_DA 3 DA - mem result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(sub),swapBT; 
*: ram[pc]->acum,alu(sbc),jmp0,swapAD,swapBT;  
*:end;
op: 0xac ;//SBCI_DA 3 DA - mem result in DA with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(sbc),swapBT; 
*: ram[pc]->acum,alu(sbc),jmp0,swapAD,swapBT;  
*:end;
op: 0xad ;//SUB_DA_BC 3 DA - BC result in DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(sub),; 
*: alu(sbc),jmp0,swapAD;  
*:end;
op: 0xae ;//SBC_DA_BC 1 DA - BC result in DA with borrow
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(sbc),; 
*: alu(sbc),jmp0,swapAD;  
*:end;
op: 0xaf ;//CMPI_D 2 D is compared to value in memeory result in D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->acum,alu(cmp),inc(pc),jmp0,swapBT,swapAD;  
*:end;
// 
// Hex B0 spare
//
op: 0xB0; //LD_H_X 1 Load H from mem with MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGH,jmp0;
*: end;
op: 0xb1; //MOV_CB_HL 1 Move CB to HL
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->REGL, ; 
*: REGC->REGH,jmp0 ;
*:end ;
op: 0xb2; //MOV_CB_DA 1 Move CB to DA
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->REGA, ; 
*: REGC->REGD,jmp0 ;
*:end ;
op: 0xb3; //MOV_DA_CB 1 Move DA to HL
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->REGB, ; 
*: REGD->REGC,jmp0 ;
*:end ;
op: 0xb4; //MOV_DA_SP 1 Move DA to SP
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->sp[lsb], ; 
*: REGD->sp[msb],jmp0 ;
*:end ;
op: 0xb5; //MOV_DA_X 1 Move DA to X reg
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->mar[lsb], ; 
*: REGD->mar[msb],jmp0 ;
*:end ;
op: 0xb6; //MOV_DA_Y 1 Move DA to Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->Y[lsb], ; 
*: REGC->Y[msb],jmp0 ;
*:end ;
op: 0xb7; //ST_H_X 1 Write H to mem with X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->ram[mar],jmp0;
*: end;
op: 0xb8; //ST_H_Y 1 Write H to mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGH->ram[Y],jmp0;
*: end;
op: 0xb9; //ST_L_Y 1 Write L to mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->ram[Y],jmp0;
*: end;
//
// Hex C0 spare
// Some 16 bit operations
op: 0xc0; //MOV_DA_HL 1 Move DA to HL
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->REGL, ; 
*: REGD->REGH,jmp0 ;
*: end
op: 0xc1 ; //LDIHL 3 load HL immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGL,inc(pc) ;
*: ram[pc]->REGH,inc(pc),jmp0  ;
*: end;
op: 0xc2 ; //LDIDA 3 load DA immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGA,inc(pc) ;
*: ram[pc]->REGD,inc(pc),jmp0  ;
*: end;
op: 0xc3 ; //LDICB 3 load CB immediate 
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[pc]->REGB,inc(pc) ;
*: ram[pc]->REGC,inc(pc),jmp0  ;
*: end;
op: 0xc4; //LD_HL_+Y 1 Load HL from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGL,inc(Y); lsb
*: ram[Y]->REGH,inc(Y),jmp0; msb
*: end;
op: 0xc5; //LD_HL_+X 1 Load HL from mem pointed by Y and inc Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGL,inc(mar);
*: ram[mar]->REGH,inc(mar),jmp0;
*: end;
op: 0xc6; //LD_CB_+Y 1 Load CB from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGB,inc(Y); lsb
*: ram[Y]->REGC,inc(Y),jmp0; msb
*: end;
op: 0xc7; //LD_CB_+X 1 Load CB from mem pointed by Y and inc Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGB,inc(mar);
*: ram[mar]->REGC,inc(mar),jmp0;
*: end;
op: 0xc8; //ST_HL_+Y 1 Store HL from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->ram[Y],inc(Y); lsb
*: REGH->ram[Y],inc(Y),jmp0; msb
*: end;
op: 0xc9; //ST_HL_+X 1 Store HL from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGL->ram[mar],inc(mar);
*: REGH->ram[mar],inc(mar),jmp0;
*: end;
op: 0xca; //ST_CB_+Y 1 STORE CB from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->ram[Y],inc(Y); lsb
*: REGC->ram[Y],inc(Y),jmp0; msb
*: end;
op: 0xcb; //ST_CB_+X 1 STORE CB from mem pointed by Y and inc Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGB->ram[mar],inc(mar);
*: REGC->ram[mar],inc(mar),jmp0;
*: end;
op: 0xcc ; //XOR_D_C 1 XOR D to reg D store result in D
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: alu(xor),jmp0,swapAD; 
*:end;
op: 0xcd; //ST_DA_+X 1 STORE CB from mem pointed by X and inc X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->ram[mar],inc(mar); LSB
*: REGD->ram[mar],inc(mar),jmp0; MSB
*: end;
op: 0xce; //ST_DA_+Y 1 STORE CB from mem pointed by Y and inc Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGA->ram[Y],inc(Y); LSB
*: REGD->ram[Y],inc(Y),jmp0; MSB
*: end;
//
// Hex D0 spare
//
op: 0xd0; //LD_B_+X 1 Load B from mem with MAR and inc MAR
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[mar]->REGB,inc(mar),jmp0;
*: end;
op: 0xd1; //LD_B_+Y 1 Load B from mem with Y and inc Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGB,inc(Y),jmp0;
*: end;
op: 0xd2; //LD_C_Y 1 Load C from mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGC,jmp0;
*: end;
op: 0xd3; //LD_D_Y 1 Load D from mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGD,jmp0;
*: end;
op: 0xd4; //LD_L_Y 1 Load L from mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGL,jmp0;
*: end;
op: 0xd5; //LD_H_Y 1 Load H from mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGH,jmp0;
*: end;
op: 0xd6; //LD_B_Y 1 Load B from mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: ram[Y]->REGB,inc(Y),jmp0;
*: end;
op: 0xd7; //ST_D_+Y 1 Write D to mem with Y
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGD->ram[Y],jmp0;
*: end;
op: 0xd8; //ST_D_+X 1 Write D to mem with X
*: ram[pc]->instr,inc(pc) ; //basic istruction fetch
*: REGD->ram[mar],inc(mar),jmp0;
*: end;
//
// Hex E0 spare
//
//
// Hex F0 spare
//