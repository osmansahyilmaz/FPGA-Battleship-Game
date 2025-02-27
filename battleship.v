// DO NOT MODIFY THE MODULE NAMES, SIGNAL NAMES, SIGNAL PROPERTIES

module battleship (
  input            clk  ,
  input            rst  ,
  input            start,
  input      [1:0] X    ,
  input      [1:0] Y    ,
  input            pAb  ,
  input            pBb  ,
  output reg [7:0] disp0,
  output reg [7:0] disp1,
  output reg [7:0] disp2,
  output reg [7:0] disp3,
  output reg [7:0] led
);

/* Your design goes here. */
reg [1:0] A_IN_COUNT = 2'b0;
reg [15:0] A_MATRIX = 16'b0;
reg [2:0] A_SCORE = 3'b0;


reg [1:0] B_IN_COUNT = 2'b0;
reg [15:0] B_MATRIX = 16'b0;
reg [2:0] B_SCORE = 3'b0;

parameter IDLE_STATE = 0, IS_RESET = 14;
parameter SHOW_A = 1, A_IN = 2, ERROR_A = 3;
parameter A_SHOOT = 4, A_SINK = 5, A_WIN = 6;
parameter SHOW_B = 7, B_IN = 8, ERROR_B = 9;
parameter B_SHOOT = 10, B_SINK = 11, B_WIN = 12;
parameter SHOW_SCORE = 13;

reg Z = 0;
reg [2:0]led_dance_time = 3'b0;
reg [6:0] timer_limit = 0;
reg [3:0] current_state = IS_RESET;
reg [3:0] next_state;


/* Your design goes here. */

always @(posedge clk) begin
  if (rst == 1) begin
    timer_limit <= 0;
  end else begin
      if (current_state == IS_RESET) begin
        timer_limit <= 0;
      end
      else if (current_state == IDLE_STATE) begin
        if(start == 1) begin
          timer_limit <= 0;
        end else begin
          timer_limit <= timer_limit + 1;
        end
      end
      else if (current_state == SHOW_A) begin
        if(start == 1) begin
          timer_limit <= 0;
        end else begin
          timer_limit <= timer_limit + 1;
        end
      end
      else if (current_state == A_IN) begin
        timer_limit <= 0;
      end
      else if (current_state == ERROR_A)begin
        timer_limit <= timer_limit + 1;
      end
      else if (current_state == SHOW_B) begin
        if(timer_limit > 50) begin 
          timer_limit <= 0;
        end else begin
          timer_limit <= timer_limit + 1;
        end
      end
      else if (current_state == B_IN) begin
        timer_limit <= 0;
      end
      else if (current_state == ERROR_B) begin
        timer_limit <= timer_limit + 1;
      end
      else if (current_state == SHOW_SCORE) begin
        if(timer_limit > 50) begin 
          timer_limit <= 0;
        end else begin
          timer_limit <= timer_limit + 1;
        end
      end
      else if (current_state == A_SHOOT) begin
        timer_limit <= 0;
      end
      else if (current_state == A_SINK) begin
        if(timer_limit == 75) begin 
          timer_limit <= timer_limit;
        end else begin
          timer_limit <= timer_limit + 1;
        end
      end
      else if (current_state == A_WIN) begin
        timer_limit <= timer_limit + 1;
      end
      else if (current_state == B_SHOOT) begin
        timer_limit <= 0;
      end
      else if (current_state == B_SINK) begin
        if(timer_limit == 75) begin 
          timer_limit <= timer_limit;
        end else begin
          timer_limit <= timer_limit + 1;
        end
      end
      else if (current_state == B_WIN) begin
        timer_limit <= timer_limit + 1;
      end
      else begin
        timer_limit <= timer_limit + 1;
      end
  end
end

// sequential part - state transitions
always @ (posedge clk)
begin
  if(rst == 1) begin
    current_state <= IS_RESET;
  end else begin
    current_state <= next_state;
  end
end

always @(posedge clk) begin
  if (led_dance_time == 3'b111) begin
    led_dance_time <= 3'b0; 
  end else begin
    led_dance_time <= led_dance_time + 3'b001;
  end 
end

always @(posedge clk) begin
  if (rst == 1) begin
    A_SCORE <= 3'b0;
    B_SCORE <= 3'b0;
    A_IN_COUNT <= 2'b0;
    B_IN_COUNT <= 2'b0;
  end else begin
    if (current_state == IS_RESET) begin
      A_SCORE <= 3'b0;
      B_SCORE <= 3'b0;
      A_IN_COUNT <= 2'b0;
      B_IN_COUNT <= 2'b0;
    end else if (current_state == A_IN) begin
      if (pAb) begin
        if (A_MATRIX[(4*X) + Y] == 1'b1) begin
        end else begin  
          if (A_IN_COUNT > 2) begin
          end else begin
            A_IN_COUNT <= A_IN_COUNT + 1'b1;
          end
        end
      end
    end else if (current_state == B_IN) begin
      if (pBb) begin
        if (B_MATRIX[(4*X) + Y] == 1'b1) begin
        end else begin
          if (B_IN_COUNT > 2) begin
          end else begin
            B_IN_COUNT <= B_IN_COUNT + 1'b1;
          end
        end
      end
    end else if (current_state == A_SHOOT) begin
      if (pAb) begin
        if (B_MATRIX[4*X + Y] == 1) begin
          A_SCORE <= A_SCORE + 1;
          Z <= 1;
        end else begin
          A_SCORE <= A_SCORE;
          Z <= 0;
        end
      end
    end else if (current_state == B_SHOOT) begin
      if (pBb) begin
        if (A_MATRIX[4*X + Y] == 1) begin
          B_SCORE <= B_SCORE + 1;
          Z <= 1;
        end else begin
          B_SCORE <= B_SCORE;
          Z <= 0;
        end
      end
    end
  end
end

always @(posedge clk) begin
  if (rst == 1) begin
    A_MATRIX <= 16'b0;
    B_MATRIX <= 16'b0;
  end else begin
    if (current_state == A_IN && pAb && A_MATRIX[(4*X) + Y] == 1'b0) begin
      A_MATRIX[(4*X) + Y] <= 1'b1;
    end else if (current_state == B_IN && pBb && B_MATRIX[(4*X) + Y] == 1'b0) begin
      B_MATRIX[(4*X) + Y] <= 1'b1;
    end else if (current_state == A_SHOOT && pAb && B_MATRIX[4*X + Y] == 1) begin
      B_MATRIX[4*X + Y] <= 1'b0;
    end else if (current_state == B_SHOOT && pBb && A_MATRIX[4*X + Y] == 1) begin
      A_MATRIX[4*X + Y] <= 1'b0;
    end
  end
end



// combinational part - next state definitions
always @(*)
begin
  next_state = current_state;
  case (current_state)
    IDLE_STATE: begin
      led = 8'b10011001;

      disp3 = 8'b00000110;
      disp2 = 8'b01011110;
      disp1 = 8'b00111000;
      disp0 = 8'b01111001;
      
      if(start == 1) begin
        next_state = SHOW_A;
      end else begin 
        next_state = IDLE_STATE;
      end
    end
    
    SHOW_A: begin
      led = 8'b10011001;
      disp3 = 8'b01110111;
      disp2 = 8'b0;
      disp1 = 8'b0;
      disp0 = 8'b0;
      // TIMEEERRRRRR
      if(timer_limit > 50) begin 
        next_state = A_IN;
      end
      else begin
        next_state = SHOW_A;
      end
    end

    A_IN: begin
      case (A_IN_COUNT)
      0: 
        begin
          led = 8'b10000000;
        end
      1:
        begin
          led = 8'b10010000;
        end
      2:
        begin
          led = 8'b10100000;
        end
      3:
        begin
          led = 8'b10110000;
        end
      default begin
        led = 8'b0;
      end
    endcase

      disp3 = 0;
      disp2 = 0;
    
    // disp1 based on X
    case (X)
    0: 
      begin
        disp1 = 8'b00111111;
      end
    1:
      begin
        disp1 = 8'b00000110;
      end
    2:
      begin
        disp1 = 8'b01011011;
      end
    3:
      begin
        disp1 = 8'b01001111;
      end
    default begin
      disp1 = 8'b0;
    end
  endcase

  // disp0 based on Y
  case (Y)
    0: 
      begin
        disp0 = 8'b00111111;
      end
    1:
      begin
        disp0 = 8'b00000110;
      end
    2:
      begin
        disp0 = 8'b01011011;
      end
    3:
      begin
        disp0 = 8'b01001111;
      end
    default begin
      disp0 = 8'b0;
    end
  endcase

    if (pAb) begin
      if (A_MATRIX[(4*X) + Y] == 1'b1) begin
        next_state = ERROR_A; 
      end
      else begin  
        if (A_IN_COUNT > 2) begin
          next_state = SHOW_B;
        end else begin
          next_state = A_IN;
        end
      end
    end 
    else begin
      next_state = A_IN;
    end
  end

  ERROR_A: begin
    led = 8'b10011001;

    disp3 = 8'b01111001;
    disp2 = 8'b01010000;
    disp1 = 8'b01010000;
    disp0 = 8'b01011100;
    
    if(timer_limit > 50) begin 
      next_state = A_IN;
    end
    else begin
      next_state = ERROR_A;
    end
  end

  SHOW_B: begin
     //LED&SSD
    led = 8'b10011001;
    
    disp3 = 8'b01111100;
    disp2 = 8'b0;
    disp1 = 8'b0;
    disp0 = 8'b0;
    
    if(timer_limit > 50) begin 
      next_state = B_IN;
    end
    else begin
      next_state = SHOW_B;
    end
  end

  B_IN: begin
      //LED&SSD
      led = 8'b00000001;
      
      case (B_IN_COUNT)
        0: 
          begin
            led[3] = 0;
            led[2] = 0;
          end
        1:
          begin
            led[3] = 0;
            led[2] = 1;
          end
        2:
          begin
            led[3] = 1;
            led[2] = 0;
          end
        3:
          begin
            led[3] = 1;
            led[2] = 1;
          end
        default begin
          led[3] = 0;
          led[2] = 0;
        end
      endcase

      // SSD
      disp3 = 0;
      disp2 = 0;
      // disp1 based on X
      case (X)
        0: 
          begin
            disp1 = 8'b00111111;
          end
        1:
          begin
            disp1 = 8'b00000110;
          end
        2:
          begin
            disp1 = 8'b01011011;
          end
        3:
          begin
            disp1 = 8'b01001111;
          end
        default begin
          disp1 = 8'b0;
        end
      endcase

      // disp0 based on Y
      case (Y)
        0: 
          begin
            disp0 = 8'b00111111;
          end
        1:
          begin
            disp0 = 8'b00000110;
          end
        2:
          begin
            disp0 = 8'b01011011;
          end
        3:
          begin
            disp0 = 8'b01001111;
          end
        default begin
          disp0 = 8'b0;
        end
      endcase

      if (pBb) begin
        if (B_MATRIX[(4*X) + Y] == 1'b1) begin
          next_state = ERROR_B;
        end
        else begin
          if (B_IN_COUNT > 2) begin
            next_state = SHOW_SCORE;
          end
          else begin
            next_state = B_IN;
          end
        end
      end else begin
        next_state = B_IN;
      end
      
    end

    ERROR_B: begin
      //LED&SSD
      led = 8'b10011001;
      disp3 = 8'b01111001;
      disp2 = 8'b01010000;
      disp1 = 8'b01010000;
      disp0 = 8'b01011100;
      if(timer_limit > 50) begin 
        next_state = B_IN;
      end
      else begin
        next_state = ERROR_B;
      end
    end

    SHOW_SCORE: begin
      //LED&SSD
      led = 8'b10011001;
      disp3 = 8'b0;
      disp2 = 8'b00111111;
      disp1 = 8'b01000000;
      disp0 = 8'b00111111;
      if(timer_limit > 50) begin 
        next_state = A_SHOOT;
      end
      else begin
        next_state = SHOW_SCORE;
      end
    end

    A_SHOOT: begin
      led = 8'b10000000;
      //SSD
      disp3 = 0;
      disp2 = 0;
      // disp1 based on X
      case (X)
        0: 
          begin
            disp1 = 8'b00111111;
          end
        1:
          begin
            disp1 = 8'b00000110;
          end
        2:
          begin
            disp1 = 8'b01011011;
          end
        3:
          begin
            disp1 = 8'b01001111;
          end
        default begin
          disp1 = 8'b0;
        end
      endcase

      // disp0 based on Y
      case (Y)
        0: 
          begin
            disp0 = 8'b00111111;
          end
        1:
          begin
            disp0 = 8'b00000110;
          end
        2:
          begin
            disp0 = 8'b01011011;
          end
        3:
          begin
            disp0 = 8'b01001111;
          end
        default begin
          disp0 = 8'b0;
        end
      endcase

      if (pAb) begin
        if (B_MATRIX[4*X + Y] == 1) begin
          
          next_state = A_SINK;
        end
        else begin
          next_state = A_SINK;
        end
      end
      else begin
        next_state = A_SHOOT;
      end
    
      case (A_SCORE)
        0: 
          begin
            led[5] = 0;
            led[4] = 0;
          end
        1:
          begin
            led[5] = 0;
            led[4] = 1;
          end
        2:
          begin
            led[5] = 1;
            led[4] = 0;
          end
        3:
          begin
            led[5] = 1;
            led[4] = 1;
          end
        default begin
          led[5] = 0;
          led[4] = 0;
        end
      endcase

      case (B_SCORE)
        0: 
          begin
            led[3] = 0;
            led[2] = 0;
          end
        1:
          begin
            led[3] = 0;
            led[2] = 1;
          end
        2:
          begin
            led[3] = 1;
            led[2] = 0;
          end
        3:
          begin
            led[3] = 1;
            led[2] = 1;
          end
        default begin
          led[3] = 0;
          led[2] = 0;
        end
      endcase
    end

    A_SINK: begin
      // SHOWING SCORES
      disp3 = 8'b0;
      case (A_SCORE)
        0: 
          begin
            disp2 = 8'b00111111;
          end
        1:
          begin
            disp2 = 8'b00000110;
          end
        2:
          begin
            disp2 = 8'b01011011;
          end
        3:
          begin
            disp2 = 8'b01001111;
          end
        4:
          begin
            disp2 = 8'b01100110;
          end
        default begin
          disp2 = 8'b0;
        end
      endcase

      disp1 = 8'b01000000;

      case (B_SCORE)
        0: 
          begin
            disp0 = 8'b00111111;
          end
        1:
          begin
            disp0 = 8'b00000110;
          end
        2:
          begin
            disp0 = 8'b01011011;
          end
        3:
          begin
            disp0 = 8'b01001111;
          end
        4:
          begin
            disp0 = 8'b01100110;
          end
        default begin
          disp0 = 8'b0;
        end
        endcase

        if (Z) begin
          led = 8'b11111111;
        end
        else begin
          led = 8'b0;
        end

        if(timer_limit == 75) begin 
          if (A_SCORE == 3'b100) begin
              next_state = A_WIN;
          end
          else begin
              next_state = B_SHOOT;
          end
        end
        else begin
          next_state = A_SINK;
        end
  end
    
    A_WIN: begin
      next_state = A_WIN;
      disp3 = 8'b01110111;
      // SHOWING SCORES
      case (A_SCORE)
        0: 
          begin
            disp2 = 8'b00111111;
          end
        1:
          begin
            disp2 = 8'b00000110;
          end
        2:
          begin
            disp2 = 8'b01011011;
          end
        3:
          begin
            disp2 = 8'b01001111;
          end
        4:
          begin
            disp2 = 8'b01100110;
          end
        default begin
          disp2 = 8'b0;
        end
      endcase
      disp1 = 8'b01000000;
      case (B_SCORE)
        0: 
          begin
            disp0 = 8'b00111111;
          end
        1:
          begin
            disp0 = 8'b00000110;
          end
        2:
          begin
            disp0 = 8'b01011011;
          end
        3:
          begin
            disp0 = 8'b01001111;
          end
        4:
          begin
            disp0 = 8'b01100110;
          end
        default begin
          disp0 = 8'b0;
        end
      endcase
      //LEDDDDANCCEEEEEEEEE
      case (led_dance_time)
        0: 
        begin
        led = 8'b10000001;
        end
        1:
        begin
         led = 8'b01000010;
        end
        2:
        begin
         led = 8'b00100100;
        end
        3:
        begin
         led = 8'b00011000;
        end
        4:
        begin
        led = 8'b00011000;
        end
        5:
        begin
        led = 8'b00100100;
        end
        6:
        begin
        led = 8'b01000010;
        end
        7:
        begin
        led = 8'b10000001;
        end
        default begin
        led = 8'b0;
        end
        endcase
    end
    
    B_SHOOT: begin
      //LED
      led = 8'b00000001;
      //SSD
      disp3 = 0;
      disp2 = 0;
      // disp1 based on X
      case (X)
        0: 
          begin
            disp1 = 8'b00111111;
          end
        1:
          begin
            disp1 = 8'b00000110;
          end
        2:
          begin
            disp1 = 8'b01011011;
          end
        3:
          begin
            disp1 = 8'b01001111;
          end
        default begin
          disp1 = 8'b0;
        end
      endcase

      // disp0 based on Y
      case (Y)
        0: 
          begin
            disp0 = 8'b00111111;
          end
        1:
          begin
            disp0 = 8'b00000110;
          end
        2:
          begin
            disp0 = 8'b01011011;
          end
        3:
          begin
            disp0 = 8'b01001111;
          end
        default begin
          disp0 = 8'b0;
        end
      endcase
    
      if (pBb) begin
        if (A_MATRIX[4*X + Y] == 1) begin
          
          next_state = B_SINK;
        end
        else begin
          next_state = B_SINK;
        end
      end
      else begin
        next_state = B_SHOOT;
      end

      case (A_SCORE)
        0: 
          begin
            led[5] = 0;
            led[4] = 0;
          end
        1:
          begin
            led[5] = 0;
            led[4] = 1;
          end
        2:
          begin
            led[5] = 1;
            led[4] = 0;
          end
        3:
          begin
            led[5] = 1;
            led[4] = 1;
          end
        default begin
          led[5] = 0;
          led[4] = 0;
        end
      endcase

      case (B_SCORE)
        0: 
          begin
            led[3] = 0;
            led[2] = 0;
          end
        1:
          begin
            led[3] = 0;
            led[2] = 1;
          end
        2:
          begin
            led[3] = 1;
            led[2] = 0;
          end
        3:
          begin
            led[3] = 1;
            led[2] = 1;
          end
        default begin
          led[3] = 0;
          led[2] = 0;
        end
      endcase
    end

    B_SINK: begin
      disp3 = 8'b0;
      // SHOWING SCORES

      case (A_SCORE)
        0: 
          begin
            disp2 = 8'b00111111;
          end
        1:
          begin
            disp2 = 8'b00000110;
          end
        2:
          begin
            disp2 = 8'b01011011;
          end
        3:
          begin
            disp2 = 8'b01001111;
          end
        4:
          begin
            disp2 = 8'b01100110;
          end
        default begin
          disp2 = 8'b0;
        end
      endcase

      disp1 = 8'b01000000;

      case (B_SCORE)
        0: 
          begin
            disp0 = 8'b00111111;
          end
        1:
          begin
            disp0 = 8'b00000110;
          end
        2:
          begin
            disp0 = 8'b01011011;
          end
        3:
          begin
            disp0 = 8'b01001111;
          end
        4:
          begin
            disp0 = 8'b01100110;
          end
        default begin
          disp0 = 8'b0;
        end
      endcase

      if (Z) begin
        led = 8'b11111111;
      end
      else begin
        led = 8'b0;
      end

      if(timer_limit == 75) begin 
        if (B_SCORE == 3'b100) begin
          next_state = B_WIN;
        end
        else begin
          next_state = A_SHOOT;
        end
      end
      else begin
        next_state = B_SINK;
      end

    end

    B_WIN: begin
      next_state = B_WIN;
      disp3 = 8'b01111100;
      // SHOWING SCORES
      case (A_SCORE)
        0: 
          begin
            disp2 = 8'b00111111;
          end
        1:
          begin
            disp2 = 8'b00000110;
          end
        2:
          begin
            disp2 = 8'b01011011;
          end
        3:
          begin
            disp2 = 8'b01001111;
          end
        4:
          begin
            disp2 = 8'b01100110;
          end
        default begin
          disp2 = 8'b0;
        end
      endcase

      disp1 = 8'b01000000;
      
      case (B_SCORE)
        0: 
          begin
            disp0 = 8'b00111111;
          end
        1:
          begin
            disp0 = 8'b00000110;
          end
        2:
          begin
            disp0 = 8'b01011011;
          end
        3:
          begin
            disp0 = 8'b01001111;
          end
        4:
          begin
            disp0 = 8'b01100110;
          end
        default begin
          disp0 = 8'b0;
        end
      endcase

      case (led_dance_time)
        0: 
        begin
        led = 8'b10000001;
        end
        1:
        begin
         led = 8'b01000010;
        end
        2:
        begin
         led = 8'b00100100;
        end
        3:
        begin
         led = 8'b00011000;
        end
        4:
        begin
        led = 8'b00011000;
        end
        5:
        begin
        led = 8'b00100100;
        end
        6:
        begin
        led = 8'b01000010;
        end
        7:
        begin
        led = 8'b10000001;
        end
        default begin
        led = 8'b0;
        end
        endcase
      end

      IS_RESET: begin
        led = 8'b0;
        disp3 = 8'b01010000;
        disp2 = 8'b01111001;
        disp1 = 8'b01101101;
        disp0 = 8'b01111001;
        next_state = IDLE_STATE;
      end

      default begin
        led = 8'b0;
        disp3 = 8'b01010000;
        disp2 = 8'b01111001;
        disp1 = 8'b01101101;
        disp0 = 8'b01111001;
        next_state = IDLE_STATE;
      end
  endcase
end

endmodule