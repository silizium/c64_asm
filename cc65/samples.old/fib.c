#include <stdio.h>
int main()
	int a=0, b=1, c;
	for(int i=0; i<2000; ++i){
		printf("%d: %d", i, b);
		c=a+b; a=b; b=c;
	}
