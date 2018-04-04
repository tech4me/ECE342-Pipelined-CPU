#include <iostream>
#include <fstream>
#include <sstream>
#include <string>

uint16_t rf[8];
bool z;
bool n;

uint8_t mem[65536];

void print_rf()
{
    //std::cout << "Printing all registers!" << std::endl;
    for (int i = 0; i < 8; ++i)
        std::cout << "R" << i << ":" << rf[i] << " ";
    std::cout << std::endl;
}

void print_mem(int start, int len)
{
    std::cout << "Printing memory!" << std::endl;
    for (int i = start; i < start + len; ++i)
        std::cout << "MEM" << i << ":" << mem[i] << std::endl;
    std::cout << std::endl;
}

enum instruction_type
{
    MV = 0b00000,
    ADD = 0b00001,
    SUB = 0b00010,
    CMP = 0b00011,
    LD = 0b00100,
    ST = 0b00101,
    MVI = 0b10000,
    ADDI = 0b10001,
    SUBI = 0b10010,
    CMPI = 0b10011,
    MVHI = 0b10110,
    JR = 0b01000,
    JZR = 0b01001,
    JNR = 0b01010,
    CALLR= 0b01100,
    J = 0b11000,
    JZ = 0b11001,
    JN = 0b11010,
    CALL = 0b11100
};

class Instruction
{
    public:
    instruction_type type;
    uint16_t rx;
    uint16_t ry;
    uint16_t imm8;
    uint16_t imm11;
    Instruction(uint16_t addr)
    {
        uint16_t instr = ((uint16_t)mem[addr + 1] << 8) | mem[addr];
        type = (instruction_type)(instr & 0x001F);
        rx = (instr & 0x00E0) >> 5;
        ry = (instr & 0x0700) >> 8;
        imm8 = (instr & 0xFF00) >> 8;
        imm11 = (instr & 0xFFE0) >> 5;
    };
};

uint16_t execute_instruction(uint16_t pc)
{
    Instruction i(pc);
    pc += 2;
    uint16_t temp;
    switch(i.type)
    {
        case MV:
            std::cout << "Executing MV: Rx:" << i.rx << " Ry:" << i.ry << std::endl;
            rf[i.rx] = rf[i.ry];
        break;
        case ADD:
            std::cout << "Executing ADD: Rx:" << i.rx << " Ry:" << i.ry << std::endl;
            rf[i.rx] = rf[i.rx] + rf[i.ry];
            z = (rf[i.rx] == 0);
            n = ((rf[i.rx] >> 15) == 1);
        break;
        case SUB:
            std::cout << "Executing SUB: Rx:" << i.rx << " Ry:" << i.ry << std::endl;
            rf[i.rx] = rf[i.rx] - rf[i.ry];
            z = (rf[i.rx] == 0);
            n = ((rf[i.rx] >> 15) == 1);
        break;
        case CMP:
            std::cout << "Executing CMP: Rx:" << i.rx << " Ry:" << i.ry << std::endl;
            temp = rf[i.rx] - rf[i.ry];
            z = (temp == 0);
            n = ((temp >> 15) == 1);
        break;
        case LD:
            std::cout << "Executing LD: Rx:" << i.rx << " Ry:" << i.ry << std::endl;
            rf[i.rx] = ((uint16_t)mem[rf[i.ry] + 1] << 8) | mem[rf[i.ry]];
        break;
        case ST:
            std::cout << "Executing ST: Rx:" << i.rx << " Ry:" << i.ry << std::endl;
            mem[rf[i.ry]] = rf[i.rx] & 0x00FF;
            mem[rf[i.ry] + 1] = (rf[i.rx] & 0xFF00) >> 8;
        break;
        case MVI:
            std::cout << "Executing MVI: Rx:" << i.rx << " imm8:" << i.imm8 << std::endl;
            rf[i.rx] = (i.imm8 & 0x00FF) | ((i.imm8 & 0x0080) ? 0xFF00 : 0);
        break;
        case ADDI:
            std::cout << "Executing ADDI: Rx:" << i.rx << " imm8:" << i.imm8 << std::endl;
            rf[i.rx] = rf[i.rx] + ((i.imm8 & 0x00FF) | ((i.imm8 & 0x0080) ? 0xFF00 : 0));
            z = (rf[i.rx] == 0);
            n = ((rf[i.rx] >> 15) == 1);
        break;
        case SUBI:
            std::cout << "Executing SUBI: Rx:" << i.rx << " imm8:" << i.imm8 << std::endl;
            rf[i.rx] = rf[i.rx] - ((i.imm8 & 0x00FF) | ((i.imm8 & 0x0080) ? 0xFF00 : 0));
            z = (rf[i.rx] == 0);
            n = ((rf[i.rx] >> 15) == 1);
        break;
        case CMPI:
            std::cout << "Executing CMPI: Rx:" << i.rx << " imm8:" << i.imm8 << std::endl;
            temp = rf[i.rx] - ((i.imm8 & 0x00FF) | ((i.imm8 & 0x0080) ? 0xFF00 : 0));
            z = (temp == 0);
            n = ((temp >> 15) == 1);
        break;
        case MVHI:
            std::cout << "Executing MVHI: Rx:" << i.rx << " imm8:" << i.imm8 << std::endl;
            rf[i.rx] = (i.imm8 << 8) | (rf[i.rx] & 0x00FF);
        break;
        case JR:
            std::cout << "Executing JR: Rx:" << i.rx << std::endl;
            pc = rf[i.rx];
        break;
        case JZR:
            std::cout << "Executing JZR: Rx:" << i.rx << std::endl;
            if (z == 1)
                pc = rf[i.rx];
        break;
        case JNR:
            std::cout << "Executing JNR: Rx:" << i.rx << std::endl;
            if (n == 1)
                pc = rf[i.rx];
        break;
        case CALLR:
            std::cout << "Executing CALLR: Rx:" << i.rx << std::endl;
            temp = pc;
            pc = rf[i.rx];
            rf[7] = temp;
        break;
        case J:
            std::cout << "Executing J: imm11:" << i.imm11 << std::endl;
            pc = pc + 2 * ((i.imm11 & 0x07FF) | ((i.imm11 & 0x0400) ? 0xF800 : 0));
        break;
        case JZ:
            std::cout << "Executing JZ: imm11:" << i.imm11 << std::endl;
            if (z == 1)
                pc = pc + 2 * ((i.imm11 & 0x07FF) | ((i.imm11 & 0x0400) ? 0xF800 : 0));
        break;
        case JN:
            std::cout << "Executing JN: imm11:" << i.imm11 << std::endl;
            if (n == 1)
                pc = pc + 2 * ((i.imm11 & 0x07FF) | ((i.imm11 & 0x0400) ? 0xF800 : 0));
        break;
        case CALL:
            std::cout << "Executing CALL: imm11:" << i.imm11 << std::endl;
            rf[7] = pc;
            pc = pc + 2 * ((i.imm11 & 0x07FF) | ((i.imm11 & 0x0400) ? 0xF800 : 0));
        break;
    }
    //std::cout << "New PC=" << pc << std::endl;
    //print_rf();
    return pc;
}

uint16_t branch_always_nottaken(uint16_t pc)
{
    return pc + 2;
}

struct btb_entry
{
    bool valid = 0;
    int history = -1;
    uint16_t pc = 0xFFFF;
};

btb_entry btb[65536];

uint16_t branch_1bit_history(uint16_t pc)
{
    if (btb[pc].valid)
        return btb[pc].pc;
    else
        return pc + 2;
}

void branch_1bit_history_update(uint16_t pc, uint16_t target_pc)
{
    btb[pc].pc = target_pc;
    btb[pc].valid = 1;
}

uint16_t branch_2bit_history(uint16_t pc)
{
    switch(btb[pc].history)
    {
        case -1: case -2:
              return pc + 2;
        case 1: case 2:
              return btb[pc].pc;
    }
}

void branch_2bit_history_update(uint16_t pc, uint16_t target_pc)
{
    bool taken = ((pc + 2) != target_pc);
    std::cout << "Branch taken:" << taken << std::endl;
    btb[pc].pc = target_pc;
    if (btb[pc].history == 1)
    {
        if (taken)
            btb[pc].history = 2;
        else
            btb[pc].history = -1;
    }
    else if (btb[pc].history == 2)
    {
        if (taken)
            btb[pc].history = 2;
        else
            btb[pc].history = 1;
    }
    else if (btb[pc].history == -1)
    {
        if (taken)
            btb[pc].history = 1;
        else
            btb[pc].history = -2;
    }
    else if (btb[pc].history == -2)
    {
        if (taken)
            btb[pc].history = -1;
        else
            btb[pc].history = -2;
    }
}

int main()
{
    //std::ifstream f("0_basic.hex");
    //std::ifstream f("1_arithdep.hex");
    //std::ifstream f("2_branch_nottaken.hex");
    //std::ifstream f("3_branch_taken.hex");
    //std::ifstream f("4_memdep.hex");
    std::ifstream f("5_capital.hex");
    std::string line;
    for (uint16_t addr = 0; getline(f, line); addr+=2)
    {
        std::stringstream ss(line);
        uint16_t data;
        ss >> std::hex >> data;
        mem[addr] = data & 0x00FF;
        mem[addr + 1] = (data & 0xFF00) >> 8;
    }
    //print_mem(0x0, 0x100);
    int counter = 0;
    int correct_counter = 0;
    uint16_t pc;
    for (pc = 0; pc < 0x1000; )
    {
        // Return new pc
        uint16_t old_pc = pc;
        //uint16_t predict_pc = branch_always_nottaken(pc);
        uint16_t predict_pc = branch_2bit_history(pc);
        std::cout << "PC=" << std::hex << pc << std::endl;
        pc = execute_instruction(pc);
        print_rf();
        std::cout << "z:" << z << " n:" << n << std::endl;
        if (predict_pc == pc)
            correct_counter++;
        else
            std::cout << "Mis-predict PC=" << predict_pc << std::endl;
        counter++;
        branch_2bit_history_update(old_pc, pc);
        if (old_pc == pc)
            break;
    }
    std::cout << "Program finished! PC = " << pc << std::endl;
    std::cout << "Number of instructions executed: " << counter << std::endl;
    std::cout << "Branch prediction hit rate: " << correct_counter/(double)counter << std::endl;
    //print_rf();
    //print_mem(0x0, 0x100);
    return 0;
}
