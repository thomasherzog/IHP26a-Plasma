import pygame
import numpy as np
import sys

# --- 1. Quantized Sine LUT ---
sin4_data = [
    8, 9, 10, 12, 13, 14, 14, 15,
    15, 15, 14, 14, 13, 12, 10, 9,
    8, 6, 5, 3, 2, 1, 1, 0,
    0, 0, 1, 1, 2, 3, 5, 6
]
sin4_lut = np.array(sin4_data, dtype=np.uint8)

# --- 2. Font ROM Definition ---
# Replicating the 8x8 font hex arrays into a Python dictionary
font_bytes = {
    "A": [0x3C, 0x66, 0x66, 0x7E, 0x66, 0x66, 0x66, 0x00],
    "C": [0x3C, 0x66, 0x60, 0x60, 0x60, 0x66, 0x3C, 0x00],
    "E": [0x7E, 0x60, 0x60, 0x78, 0x60, 0x60, 0x7E, 0x00],
    "F": [0x7E, 0x60, 0x60, 0x78, 0x60, 0x60, 0x60, 0x00],
    "G": [0x3C, 0x66, 0x60, 0x6E, 0x66, 0x66, 0x3C, 0x00],
    "H": [0x66, 0x66, 0x66, 0x7E, 0x66, 0x66, 0x66, 0x00],
    "I": [0x3C, 0x18, 0x18, 0x18, 0x18, 0x18, 0x3C, 0x00],
    "K": [0x66, 0x6C, 0x78, 0x70, 0x78, 0x6C, 0x66, 0x00],
    "M": [0xC3, 0xE7, 0xFF, 0xDB, 0xC3, 0xC3, 0xC3, 0x00],
    "N": [0x66, 0x76, 0x7E, 0x7E, 0x6E, 0x66, 0x66, 0x00],
    "O": [0x3C, 0x66, 0x66, 0x66, 0x66, 0x66, 0x3C, 0x00],
    "P": [0x7C, 0x66, 0x66, 0x7C, 0x60, 0x60, 0x60, 0x00],
    "R": [0x7C, 0x66, 0x66, 0x7C, 0x6C, 0x66, 0x66, 0x00],
    "S": [0x3C, 0x66, 0x60, 0x3C, 0x06, 0x66, 0x3C, 0x00],
    "T": [0x7E, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x00],
    "U": [0x66, 0x66, 0x66, 0x66, 0x66, 0x66, 0x3C, 0x00],
    "W": [0xC3, 0xC3, 0xC3, 0xDB, 0xFF, 0xE7, 0xC3, 0x00],
    "Z": [0x7E, 0x06, 0x0C, 0x18, 0x30, 0x60, 0x7E, 0x00],
    "!": [0x18, 0x18, 0x18, 0x18, 0x18, 0x00, 0x18, 0x00],
    " ": [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00],
}

def render_string(text):
    """Parses the byte arrays into a boolean numpy array (8x8 bits per char)"""
    arr = np.zeros((8, 8 * len(text)), dtype=bool)
    for i, char in enumerate(text):
        glyph = font_bytes.get(char, font_bytes[" "])
        for row in range(8):
            byte_val = glyph[row]
            for col in range(8):
                # SV logic: current_font_row[7 - font_x] -> MSB is left-most
                bit = (byte_val >> (7 - col)) & 1
                arr[row, i*8 + col] = bit
    return arr

def main():
    WIDTH, HEIGHT = 640, 480
    
    pygame.init()
    screen = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("SV VGA Simulator - 8-Way Border Update")
    clock = pygame.time.Clock()

    X, Y = np.indices((WIDTH, HEIGHT))

    # --- 3. Pre-compute Text & Border Masks ---
    print("Synthesizing static layout masks...")
    pixel_mask = np.zeros((WIDTH, HEIGHT), dtype=bool)

    # Box 1: "THANKS FOR SPONSORING!" (Scale 2x)
    str1 = render_string("THANKS FOR SPONSORING!")
    str1_scaled = np.kron(str1, np.ones((2, 2), dtype=bool))
    pixel_mask[144:496, 190:206] = str1_scaled.T

    # Box 2: "SWISSCHIPS" (Scale 4x)
    str2 = render_string("SWISSCHIPS")
    str2_scaled = np.kron(str2, np.ones((4, 4), dtype=bool))
    pixel_mask[160:480, 240:272] = str2_scaled.T

    # Box 3: "ETH ZURICH" (Scale 2x)
    str3 = render_string("ETH ZURICH")
    str3_scaled = np.kron(str3, np.ones((2, 2), dtype=bool))
    pixel_mask[32:192, 440:456] = str3_scaled.T

    # Box 4: "THOMAS HERZOG" (Scale 2x)
    str4 = render_string("THOMAS HERZOG")
    str4_scaled = np.kron(str4, np.ones((2, 2), dtype=bool))
    pixel_mask[400:608, 440:456] = str4_scaled.T

    # 8-neighbor border mask
    border_mask = np.zeros((WIDTH, HEIGHT), dtype=bool)
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            if dx == 0 and dy == 0: continue
            border_mask |= np.roll(pixel_mask, shift=(dx, dy), axis=(0, 1))
    
    # Border is active if a neighbor has text, but the center pixel does NOT
    border_mask &= ~pixel_mask 

    # --- 4. Plasma Coordinate Setup ---
    X_sliced = (X >> 4) & 0x1F
    Y_sliced = (Y >> 4) & 0x1F
    X_plus_Y = (X_sliced + Y_sliced) & 0x1F
    X_minus_Y = (X_sliced - Y_sliced) & 0x1F

    counter = 0 
    rgb_array = np.zeros((WIDTH, HEIGHT, 3), dtype=np.uint8)

    print("Running Demoscene Simulator. Close the window to exit.")

    # --- 5. Main Loop ---
    while True:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                sys.exit()

        # Slice counter exactly as SV
        c7_3 = (counter >> 4) & 0x1F
        c8_4 = (counter >> 5) & 0x1F
        c6_2 = (counter >> 3) & 0x1F
        c9_5 = (counter >> 6) & 0x1F

        # Phase calculations
        phase1 = (X_sliced + c7_3) & 0x1F
        phase2 = (Y_sliced - c8_4) & 0x1F
        phase3 = (X_plus_Y + c6_2) & 0x1F
        phase4 = (X_minus_Y - c7_3) & 0x1F

        plasma_sum = sin4_lut[phase1] + sin4_lut[phase2] + sin4_lut[phase3] + sin4_lut[phase4]
        ps_5_1 = (plasma_sum >> 1) & 0x1F

        # Color routing
        color_r_phase = (ps_5_1 + c8_4) & 0x1F
        color_g_phase = (ps_5_1 + c9_5 + 10) & 0x1F
        color_b_phase = (ps_5_1 - c8_4 + 20) & 0x1F

        # Extract top 2 bits, map to 8-bit space (multiply by 85)
        rgb_array[..., 0] = ((sin4_lut[color_r_phase] >> 2) & 0x3) * 85
        rgb_array[..., 1] = ((sin4_lut[color_g_phase] >> 2) & 0x3) * 85
        rgb_array[..., 2] = ((sin4_lut[color_b_phase] >> 2) & 0x3) * 85

        # Compositing: Text > Border > Plasma
        rgb_array[border_mask] = [0, 0, 0]          # Black border
        rgb_array[pixel_mask] = [255, 255, 255]     # White text

        pygame.surfarray.blit_array(screen, rgb_array)
        pygame.display.flip()

        counter = (counter + 1) & 0xFFF
        clock.tick(60)

if __name__ == "__main__":
    main()