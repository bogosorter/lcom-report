# debugassaurus

_debugassaurus_ is an endless runner inspired by the Google Chrome Dino game. The player must survive as long as possible while avoiding cacti and pterodactyls.

Our version adds play/pause functionality and a high score board that records the seed used for each score. Players can replay specific runs by using a hidden feature: in the main menu, pressing a number key reveals a seed input field.

Screenshot

Video link

## Project Structure

...

## Devices

**Timer:** Used for periodic rendering and keeping track of the time. Using the interrupt frequency, we were able to control the dino's speed and score.

```c
// main.c

uint32_t timer_frequency = sys_hz();
uint32_t ticks_per_frame = timer_frequency / FPS;

// Setting up interrupt handlers
// ...

if (msg.m_notify.interrupts & timer_mask) {
    uint32_t ticks = timer_get_ticks();
    if (ticks == ticks_per_frame) {
        timer_set_ticks(0);
        // Frame logic
    }
}

// dino.c

static const double delta_time = 1 / (double) FPS;
static const double delta_speed = DINO_SPEED_INCREMENT * delta_time;
static const double delta_score = POINTS_PER_SECOND * delta_time;

// ...

void dino_step(dino_t* dino) {
    dino->speed.x += delta_speed;
    dino->position.x += dino->speed.x * delta_time;
    
    dino->score += delta_score;
    
    // ...
}
```

**Keyboard:** Used for navigation in menus and player input during the game. A simple API was added that could be used either to check if a key was pressed or to consume a key if pressed (if the consume function is called twice, the second call will return false). Character keys would were returned in a pointer passed as argument:

```c
// Jump if space is pressed
if (keyboard_is_pressed(SPACE, NULL)) dino_jump(dino);

// Pause game if esc is pressed. Esc will likely remain pressed for many frames and we only want to detect it once. As such, we consume it.
if (keyboard_consume(ESC, NULL)) state_pause();

// Get a character input
char c;
if(keyboard_consume(CHARACTER, &c)) {
    // Do something with character
}
```

**Mouse:** Used for navigation in menus.

**Video Card:** Used to display the game

This is an excerpt of `cursor.c`, which deals with both the mouse and the video card:

```c
void cursor_update() {
    if (!mouse_ready()) return;

    cursor_position_t position = state_get_cursor_position();
    
    position.x = cursor_update_within_range(position.x, mouse_delta_x(), vg_get_width() - 1);
    // For y displacement, the graphics driver disagrees with the mouse driver.
    // We opt to use the graphics driver's coordinate system, whose origin is at
    // the top-left corner.
    position.y = cursor_update_within_range(position.y, -mouse_delta_y(), vg_get_height() - 1);
    state_set_cursor_position(position);

    if (state_get_screen() == MENU && mouse_lb()) {**
        for (/* every button */) {
            if (button_get_x(button) >  position.x || button_get_y(button) > position.y) continue;
            if (button_get_x(button) + button_get_width(button) <  position.x ||
                button_get_y(button) + button_get_height(button) < position.y) continue;
            
            screen_t screen = button_get_screen(button);
            if (screen == MENU) state_menu();
            // ...
        }
    }
}
```

**Real Time Clock** Used to get the date to be kept in a highscore. The simple API that is exposed is this:

```c
typedef struct {
    uint8_t day;
    uint8_t month;
    uint8_t year;
} date_t;

int rtc_get_date(date_t *date);
```
