#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>

extern void rtc_start(void);
extern void rtc_read(const struct tm *);
extern void rtc_screen(void);
extern uint8_t rtc_secs(void);
extern void rtc_test(void);

struct tm now;

int main(int argc, char **argv){
	//rtc_start();
	//rtc_screen();
	//rtc_read(&now);
	//printf("%d\n", rtc_secs());
	rtc_test();
	return EXIT_SUCCESS;
}
