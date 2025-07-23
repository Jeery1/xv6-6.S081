
#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

#define NBUKETS 13

struct {
  struct spinlock lock;
  struct buf buf[NBUF];             // block[30]
  /** 实则循环双向链表  */
  // Linked list of all buffers, through prev/next. 
  // head.next is most recently used.
  //struct buf head;

  struct buf buckets[NBUKETS];
  struct spinlock bucketslock[NBUKETS];

} bcache;

int getHb(struct buf *b){
  return b->blockno % NBUKETS;
}

int getH(uint blockno){
  return blockno % NBUKETS;
}

void checkbuckets(){
  struct buf *b;
  for (int i = 0; i < NBUKETS; i++)
  {
    printf("# bucket %d:", i);
    for(b = bcache.buckets[i].next; b != &bcache.buckets[i]; b = b->next){
      printf("%d ",b->blockno);
    }
    printf("\n");
  }
  
}



void
binit(void)
{
  struct buf *b;
  /** 在head头插入b  */
  initlock(&bcache.lock, "bcache");
  
  for (int i = 0; i < NBUKETS; i++)
  {
    initlock(&bcache.bucketslock[i], "bcache.bucket");
    bcache.buckets[i].prev = &bcache.buckets[i];
    bcache.buckets[i].next = &bcache.buckets[i];
  }

  for (b = bcache.buf; b < bcache.buf + NBUF; b++)
  {
    int hash = getHb(b);
    b->time_stamp = ticks;
    b->next = bcache.buckets[hash].next;
    b->prev = &bcache.buckets[hash];
    initsleeplock(&b->lock, "buffer");
    bcache.buckets[hash].next->prev = b;
    bcache.buckets[hash].next = b;
  }
}


// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.

// Bget (kernel/bio.c:70) scans the buffer list for a buffer with the given device and sector numbers
// (kernel/bio.c:69-84). If there is such a buffer, bget acquires the sleep-lock for the buffer. Bget then
// returns the locked buffer
// sector：扇区
static struct buf*
bget(uint dev, uint blockno)
{
  int hash = getH(blockno);
  struct buf *b;
  acquire(&bcache.bucketslock[hash]);

  for(b = bcache.buckets[hash].next; b != &bcache.buckets[hash]; b = b->next){
    if(b->dev == dev && b->blockno == blockno){
      b->time_stamp = ticks;
      b->refcnt++;
      //printf("## end has \n");
      release(&bcache.bucketslock[hash]);
      acquiresleep(&b->lock);
      return b;
    }
  }
  for (int i = 0; i < NBUKETS; i++)
  {
    if(i != hash){
      acquire(&bcache.bucketslock[i]);
      for(b = bcache.buckets[i].prev; b != &bcache.buckets[i]; b = b->prev){
        if(b->refcnt == 0){
          b->time_stamp = ticks;
          b->dev = dev;
          b->blockno = blockno;
          b->valid = 0;     //important  
          b->refcnt = 1;
          
          /** 将b脱出  */
          b->next->prev = b->prev;
          b->prev->next = b->next;
          
          /** 将b接入  */
          b->next = bcache.buckets[hash].next;
          b->prev = &bcache.buckets[hash];
          bcache.buckets[hash].next->prev = b;
          bcache.buckets[hash].next = b;
          //printf("## end alloc: hash: %d, has: %d\n", hash,i);
          release(&bcache.bucketslock[i]);
          release(&bcache.bucketslock[hash]);
          acquiresleep(&b->lock);
          return b;
        }
      }
      release(&bcache.bucketslock[i]);
    }
  }
  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
// Bread (kernel/bio.c:91) calls bget to get a buffer for the given sector (kernel/bio.c:95). If the
// buffer needs to be read from disk, bread calls virtio_disk_rw to do that before returning the
// buffer.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    virtio_disk_rw(b->dev, b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b->dev, b, 1);
}

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
  //printf("#---------------------------------------- brelse! ----------------------------------------\n");
  if(!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);
  int blockno = getHb(b);
  b->time_stamp = ticks;
  if(b->time_stamp == ticks){
    b->refcnt--;
    if(b->refcnt == 0){
      /** 将b脱出  */
      b->next->prev = b->prev;
      b->prev->next = b->next;
      
      /** 将b接入  */
      b->next = bcache.buckets[blockno].next;
      b->prev = &bcache.buckets[blockno];
      bcache.buckets[blockno].next->prev = b;
      bcache.buckets[blockno].next = b;
    }
  }
}

void
bpin(struct buf *b) {
  //printf("see if bpin work\n");
  //int hash = getHb(b);
  b->time_stamp = ticks;
  if(b->time_stamp == ticks)
    b->refcnt++;
}

void
bunpin(struct buf *b) {
  //printf("see if bunpin work\n");
  b->time_stamp = ticks;
  if(b->time_stamp == ticks)
    b->refcnt--;
}

