class SelectBoxModelItem {
    private index: number;
    private label: string;
    private internalId: string;
    constructor(index: number, internalId: string, label: string) {
        this.index = index;
        this.internalId = internalId;
        this.label = label;
    }

    public getIndex(): number {
        return this.index;
    }

    public getLabel(): string {
        return this.label;
    }

    public getInternalId(): string {
        return this.internalId;
    }
}
 