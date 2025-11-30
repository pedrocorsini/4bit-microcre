module rom_8x256 (
    input wire [7:0] addr, // 8 bit address bus
    output reg [7:0] data  // 8 bit data bus
);
    // Defines the ROM memory:
    reg [7:0] rom [0:255];
    initial begin
        // Example: loading some values into the ROM
        // rom[0] = 8'hAA;
        // rom[1] = 8'hBB;
        // rom[2] = 8'hCC; 
        // The leftovers will be initialized to 0 by default
        $readmemh("rom.txt", rom);
    end
    // Read ROM data in the sensitive edge:
    always @(*) begin
        data = rom[addr];
    end
endmodule

