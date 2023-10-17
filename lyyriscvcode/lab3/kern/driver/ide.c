#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}//该函数被定义为空，即不执行任何操作。通常，这个函数可以用于初始化IDE硬盘。

#define MAX_IDE 2  //定义了MAX_IDE的值为2，表示IDE硬盘的数量上限为2。
#define MAX_DISK_NSECS 56  //表示每个IDE硬盘最多有56个扇区
static char ide[MAX_DISK_NSECS * SECTSIZE]; //静态字符数组，用于模拟IDE硬盘的存储空间。
                                            //数组的大小为MAX_DISK_NSECS * SECTSIZE，表示IDE硬盘的总容量，
                                            //每个扇区的大小为SECTSIZE字节。

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    return 0;

    //用于从指定IDE设备读取扇区数据。
    //接受设备号ideno、起始扇区号secno、目标缓冲区指针dst，以及要读取的扇区数nsecs。
    //函数会将扇区数据复制到目标缓冲区，并返回一个整数值，用于表示操作是否成功。

}

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    return 0;

    //用于向指定IDE设备写入扇区数据。
    //接受设备号ideno、起始扇区号secno、源数据缓冲区指针src,以及要写入的扇区数nsecs。
    //函数会将源数据复制到IDE硬盘的模拟存储空间中，并返回一个整数值，用于表示操作是否成功。
}
