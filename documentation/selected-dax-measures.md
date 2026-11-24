# Selected DAX measures from exported SSAS Tabular catalog

These are **existing model expressions**, not independently audited definitions. In particular, IFRS and prudential NPL logic remains unverified.

## Direct Exposure

```dax
CALCULATE([Total Exposure LCY],ExposureType[ExposureTypeKey]=1)
```

## Contigent Exposure

```dax
CALCULATE([Total Exposure LCY],ExposureType[ExposureTypeKey]=2)
```

## Total Direct & Contigent Exposure

```dax
[Direct Exposure] + [Contigent Exposure]
```

## NPL RATIO IFRS

```dax
DIVIDE([NPL IFRS],[Total Direct Exposure])
```

## NPL RATIO PRUDENTIAL

```dax
DIVIDE([NPL],[Total Direct Exposure])
```
