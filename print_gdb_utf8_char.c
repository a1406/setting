#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
//    char *p = "jack唐";
//	printf("%s\n", p);

	if (argc != 2)
		return (0);

	static char c[512];
	char tmp[4];
	tmp[3] = '\0';

	int len = strlen(argv[1]);
	int index = 0;
	
	for (int i = 0; i < len;)
	{
		if (argv[1][i] != '\\')
		{
			c[index++] = argv[1][i++];
			continue;
		}

		memcpy(&tmp[0], &argv[1][i+1], 3);
		
		c[index++] = strtoul(&tmp[0], NULL, 8);
		i += 4;
	}
	c[index] = '\0';
	printf("%s\n", c);
    return 0;
}
