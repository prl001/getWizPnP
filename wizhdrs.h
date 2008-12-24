/* header.tvwiz, header.radwiz */

struct TVWizFileHeader { /* Offest 0 */
    ushort      hidden[5];
    uchar       lock;
    uchar       mediaType;
    uchar       inRec;
    uchar       unused;
};

struct TOffset {
    uint64      lastOff;
    uint64      fileOff[8640];
};

struct TVWizTSPoint { /* offset 1024, 0x400 */
    char                svcName[256];
    char                evtName[256];
    ushort              mjd;    /* Modified Julian Date */
    ushort              pad;    /* here or after mjd? */
    ulong               start;
    ushort              last;
    ushort              sec;    /* play time = last*10 + sec */
    struct TOffset      offset;
};

/* Trunc file */
TwizOffsetFileSelection {
    uint64      wizOffset;
    ushort      fileNum;
    ushort      flags;
    uint64      offset;
    ulong       size;
};
