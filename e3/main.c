#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/moduleparam.h>

MODULE_DESCRIPTION("INIT HELLO");
int loop;
char* word;
module_param(loop, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP);
module_param(word, charp, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP);

int init_module (void)
{
	int i=0;
	for (i=0; i<loop; i++)
		printk(KERN_ALERT  "%d. %s \n", i+1 , word);
	return 0;
}

void cleanup_module ()
{
	printk (KERN_ALERT "Bye bye CSCE-3402 :) \n");
}
/*module_init(hello_init);
module_exit(hi_cleanup);*/
