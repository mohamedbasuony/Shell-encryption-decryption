#include <linux/fs.h>
#include <asm/segment.h>
#include <asm/uaccess.h>
#include <linux/buffer_head.h>
#include <linux/gfp.h>
#include <linux/module.h>
#include<linux/kernel.h>
#include<linux/moduleparam.h>
#include <linux/string.h>
#include <linux/init.h>
#include <linux/slab.h>

struct myfile{
	struct file * f;
	mm_segment_t fs; 
	loff_t pos;
};
struct myfile* open_file_for_read(char* filename)
{
	struct myfile * ff;
	mm_segment_t past_fs;
	int wrong=0;
	ff=(struct myfile*)kmalloc(sizeof(struct myfile), GFP_KERNEL| GFP_NOWAIT);
	past_fs=get_fs();
	ff->fs=get_fs();
	set_fs(get_ds());
	ff->f=filp_open(filename,O_RDONLY,0);
	set_fs(past_fs);
	if(IS_ERR(ff->f)){
		wrong=PTR_ERR(ff->f);
		return NULL;
	}
	return ff;
}
volatile int read_from_file_until (struct myfile* mf, char* buf, unsigned long vlen, char c)
{
	mm_segment_t past_fs;
	int r;
	unsigned long long trig=0;
	int i;
	int d=2;
	int t_o;
	past_fs=get_fs();
	set_fs(get_ds());
	r=vfs_read(mf->f,buf,vlen,&trig);
	for (i=0; i<vlen;i++){
		if ((buf[i]==c)&&(d==0)){
		       	buf[i]='\0';
			t_o=i+1;}
		else if (buf[i]==c) d=d-1;
	}
	buf=buf+t_o;
	set_fs(past_fs);
	return t_o;
}

void close_file(struct myfile *mf)
{
	filp_close(mf->f, NULL);
}
int init_module (void)
{
	unsigned char *buf;
	int s;
	struct myfile* ff;
	ff=open_file_for_read("/proc/version");
	buf=(unsigned char*)kmalloc(1024,GFP_KERNEL|GFP_NOWAIT);
	s=read_from_file_until(ff,buf,100,' ');
	printk(KERN_ALERT "%s\n", buf+13);
	close_file(ff);
	return 0;
}
MODULE_LICENSE("GPL");
void cleanup_module ()
{
	printk (KERN_ALERT "Bye, Done! \n");
}
