typedef struct {
	void **children;	/* ADVaryNode */
	int nChildren;
	int count;
} ADTreeNode;

typedef struct {
	void **children;	/* ADTreeNode */
	int nChildren;
	int MCV;
	int nodeI;
} ADVaryNode;

