#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_pmm.h>
#include <stdio.h>

#define IS_POWER_OF_2(x) (!((x) & (x - 1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ((index - 1) / 2)

struct Buddy
{
    unsigned *size;
    struct Page *mem_tree;
    unsigned total_size;

} buddy_manager;


size_t fix_size(size_t size)
{ // 找到最近的大于size的2的幂次
    int n = 0, tmp = size;
    while (tmp >>= 1)
    {
        n++;
    }
    n += 1;
    return (1 << n);
}

size_t round_down_size(size_t size){
    size_t n = 0;
    size_t tmp = size;
    cprintf("recieving size as %u\n",tmp);
    while (tmp >>= 1)
    {
        cprintf("%u\n",tmp);
        n++;
    }
    cprintf("done\n");
    cprintf("%u\n",&tmp);
    return (size_t)(1 << n);
}

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void buddy_init(void)
{
    list_init(&free_list);
    nr_free = 0;
}

static void buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n > 0);
    size_t round_up_n = fix_size(n);

    struct Page *p = base;
    for (; p != base + n; p++)
    {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
        //cprintf("p at %u\n",p);
        // 清空当前页框的标志和属性信息，并将页框的引用计数设置为0
    }
    p = base + n; //p指向page的最末尾

   

    buddy_manager.mem_tree = base;
    buddy_manager.size = (unsigned *)p;

   
    base->property = n; // 从base开始有n个可用页

    buddy_manager.total_size = round_up_n;

    unsigned node_size = 2 * round_up_n;

    for (int i = 0; i <2 * round_up_n - 1; ++i)
    {
        if (IS_POWER_OF_2(i + 1))
        {
            node_size /= 2;
        }
        buddy_manager.size[i] = node_size;

    }

    cprintf("initialized %u pages with a %u size tree\n",n,round_up_n);
    // SetPageProperty(base);  //设置base是一个free block的页头
    nr_free += n;
}

static struct Page *buddy_alloc_pages(size_t n)
{
    unsigned index = 0;
    unsigned node_size;
    unsigned offset = 0;

    assert(n > 0);
    
    if (!IS_POWER_OF_2(n))
    {
        n = fix_size(n);
    }
    if (n > nr_free)
    {
        return NULL;
    }
    //cprintf("alloc %u pages\n",n);
    if (buddy_manager.size[index] < n)
        return NULL;

    for (node_size = buddy_manager.total_size; node_size != n; node_size /= 2)
    {
        //cprintf("size: %u,index:%u\n",buddy_manager.total_size,index);
        if (buddy_manager.size[LEFT_LEAF(index)] >= n)
            index = LEFT_LEAF(index);
        else{
            index = RIGHT_LEAF(index);
        }
    }

    //cprintf("target index at %u\n",index);

    buddy_manager.size[index] = 0;
    offset = (index + 1) * node_size - buddy_manager.total_size;

    while (index)
    {
        index = PARENT(index);
        buddy_manager.size[index] = MAX(buddy_manager.size[LEFT_LEAF(index)], buddy_manager.size[RIGHT_LEAF(index)]);
    
    }


    struct Page *base = buddy_manager.mem_tree + offset;
    struct Page *page;

    // 将每一个取出的块由空闲态改为保留态
    for (page = base; page != base + n; page++)
    {
        ClearPageProperty(page);
    }
    nr_free -= n;
    base->property = n;  //用n来保存分配的页数，n为2的幂
    cprintf("alloc done at %u with %u pages\n",offset,n);
    return base;
}

static void buddy_free_pages(struct Page *base, size_t n)
{
    unsigned node_size, index = 0;
    unsigned left_longest, right_longest;
    int total = n;

    assert(n > 0);

    // if(n > base->property){
    //     cprintf("exceeded tail! property is %u but n is %u\n",base->property,n);
    //     n = base->property;   //当前内存块只负责释放自己申请的property个页
    //     buddy_free_pages(base+n,total-n);  //剩下total-n个页交给下一个内存块释放
    // }

    if (!IS_POWER_OF_2(n))
    {
        n = fix_size(n);
    }

    int offset = (base - buddy_manager.mem_tree);
    node_size = 1;
    index = buddy_manager.total_size + offset - 1;

    while (node_size != n)
    {
        node_size *= 2;
        index = PARENT(index);
        if (index == 0)
            return;
    }

    buddy_manager.size[index] = node_size;

    //cprintf("free at %u,node at %u, free to %u\n",offset,index,node_size);

    //cprintf("par :%u\n",buddy_manager.size[PARENT(index)]);

    while (index)
    {
        index = PARENT(index);
        node_size *= 2;
        left_longest = buddy_manager.size[LEFT_LEAF(index)];
        right_longest = buddy_manager.size[RIGHT_LEAF(index)];
        if (left_longest + right_longest == node_size){  //合并
            buddy_manager.size[index] = node_size;
        }
        else
            buddy_manager.size[index] = MAX(left_longest, right_longest);
    }
    //cprintf("top is:%u\n",buddy_manager.size[1]);

    // if(n < base->property){
    //     base->property -=(base->property - n);
    //     struct Page * next = base + n;
    //     next->property = base->property - n;
        
    // }
    nr_free+=n;
    cprintf("free done at %u with %u pages!\n",offset,n);
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {

}

static void
buddy_check(void) {
    cprintf("buddy check!\n");
    
    struct Page *p0, *A, *B, *C, *D;
    p0 = A = B = C = D = NULL;

    assert((p0 = alloc_page()) != NULL);
    assert((A = alloc_page()) != NULL);
    assert((B = alloc_page()) != NULL);


    assert(p0 != A && p0 != B && A != B);
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
    assert(A==p0+1 && B == A+1);

    free_page(p0);    
    free_page(A);
    free_page(B);
    
    A = alloc_pages(512);
    B = alloc_pages(512);
    free_pages(A, 256);
    free_pages(B, 512);
    free_pages(A + 256, 256);

    
    p0 = alloc_pages(8192);

    assert(p0 == A);

    A = alloc_pages(128);
    B = alloc_pages(64);
    // 检查是否相邻

    assert(A + 128 == B);

    
    C = alloc_pages(128);


    //检查C有没有和A重叠
    assert(A + 256 == C);
    
    //释放A
    free_pages(A, 128);
    D = alloc_pages(64);
    cprintf("D %p\n", D);

    
    
    // 检查D是否能够使用A刚刚释放的内存
    assert(D + 128 == B);
    free_pages(C, 128);
    C = alloc_pages(64);
    // 检查C是否在B、D之间
    assert(C == D + 64 && C == B - 64);
    free_pages(B, 64);
    free_pages(D, 64);
    free_pages(C, 64);
    // 全部释放
    free_pages(p0, 8192);
    
}

const struct pmm_manager buddy_pmm_manager = {
    .name = "buddy_pmm_manager",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};