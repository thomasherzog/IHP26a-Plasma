import pygame
import numpy as np
import sys

# --- 1. SystemVerilog Quantized Sine LUT ---
# Replicating the 32-entry lookup table mapping 5-bit phases to 4-bit values
sin4_data = [
    8, 9, 10, 12, 13, 14, 14, 15,
    15, 15, 14, 14, 13, 12, 10, 9,
    8, 6, 5, 3, 2, 1, 1, 0,
    0, 0, 1, 1, 2, 3, 5, 6
]

sin4_lut = np.array(sin4_data, dtype=np.uint8)

def main():
    WIDTH, HEIGHT = 640, 480
    
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("SystemVerilog Plasma Display")
    clock = pygame.time.Clock()

    # --- 2. Hardware Simulation Pre-computation ---
    # Create coordinate grids for hpos (X) and vpos (Y)
    # This acts like the pixel-coordinate inputs in the SV module
    X, Y = np.indices((WIDTH, HEIGHT))
    
    # Pre-slice X[8:4] and Y[8:4].
    # Bitwise shift right by 4, and mask with 0x1F (5 bits / modulo 32)
    X_sliced = (X >> 4) & 0x1F
    Y_sliced = (Y >> 4) & 0x1F
    
    # Precompute the static combinations to save time in the loop
    X_plus_Y = (X_sliced + Y_sliced) & 0x1F
    X_minus_Y = (X_sliced - Y_sliced) & 0x1F

    counter = 0  # 12-bit counter
    
    # Buffer for our final image (X, Y, RGB)
    rgb_array = np.zeros((WIDTH, HEIGHT, 3), dtype=np.uint8)

    print("Running Plasma Display. Close the window to exit.")

    # --- 3. Main Loop (equivalent to the continuous assignments) ---
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

        # Slice the 12-bit counter just like the SV code: counter[max:min]
        c7_3 = (counter >> 4) & 0x1F
        c8_4 = (counter >> 5) & 0x1F
        c6_2 = (counter >> 3) & 0x1F
        
        c9_5 = (counter >> 6) & 0x1F

        # Phase calculations (bitwise & 0x1F simulates 5-bit wrap-around)
        phase1 = (X_sliced + c7_3) & 0x1F
        phase2 = (Y_sliced - c8_4) & 0x1F
        phase3 = (X_plus_Y + c6_2) & 0x1F
        phase4 = (X_minus_Y - c7_3) & 0x1F

        # Fetch w1, w2, w3, w4 from the LUT
        w1 = sin4_lut[phase1]
        w2 = sin4_lut[phase2]
        w3 = sin4_lut[phase3]
        w4 = sin4_lut[phase4]

        # Plasma sum: max 15*4 = 60. Fits comfortably in an 8-bit uint matrix here.
        plasma_sum = w1 + w2 + w3 + w4
        
        # plasma_sum[5:1] is a bitwise shift right by 1, masked to 5 bits
        ps_5_1 = (plasma_sum) & 0x1F

        # Color mapping phases
        r_phase = (ps_5_1 + c8_4) & 0x1F
        g_phase = (ps_5_1 + c9_5 + 10) & 0x1F
        b_phase = (ps_5_1 - c8_4 + 20) & 0x1F

        # The SystemVerilog outputs 2-bit colors (0 to 3).
        # We multiply by 85 (255 / 3) to scale them to an 8-bit PC monitor color space.
        rgb_array[..., 0] = ((sin4_lut[r_phase] >> 2) & 0x3) * 85
        rgb_array[..., 1] = ((sin4_lut[g_phase] >> 2) & 0x3) * 85
        rgb_array[..., 2] = ((sin4_lut[b_phase] >> 2) & 0x3) * 85

        # Blit the array directly to the Pygame screen surface
        pygame.surfarray.blit_array(screen, rgb_array)
        pygame.display.flip()

        # Increment counter and wrap at 12 bits (4096)
        counter = (counter + 1) & 0xFFF
        
        # Optional: Lock to 60 FPS. Remove this line for uncapped speed.
        clock.tick(60) 

if __name__ == "__main__":
    main()