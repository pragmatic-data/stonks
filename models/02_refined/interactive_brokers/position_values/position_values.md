# Position Values

Position (daily) Values is a time serie of values for Positions while they are opened, 
with the value being zero once the position is closed.

For each position we have changed data only in dates when did an Open Positions export 
and the exchange where the Position trades was opened. 
In some days we might have the same data as the previous date.

## Identity and version definition for a Timeserie (HKey and HDiff)
When building a time-serie, based on a recognized entity (like Position in our case), 
we have two approaches:

1. Using the key of the base entity (Position) and 
   explicitly handle the time dimension (Effectivity date = Report date)
   by adding it into the HDiff, so that every new time is captured 
   as a new version of the base entity.

2. Create a key specific to the time-serie, by adding the time dimension
   in the HKey of the base entity, de-facto creating a new entity, with TS-HKey.
   We then create a normal HDiff, no need to put there the time dimension.
   If we want to keep the connection with the base entity we need to calculate
   and store also the base entity's HKey.

### Semantic differences

The choice of different identities generate a different semantic for the metadata columns 
that we calculate, like IS_CURRENT, as they are strictly related to the identity definition.
- IS_CURRENT will be true only for the last position value with definition n.1,
  while it will be true for the latest version of each daily position value with definition n.2.
- VALID_FROM and VALID_TO will also have a different semantic.
  They will cover the few days when a version is the current one with definition n.1,
  while they will start at the position value date and extend forever with definition n.2
- SCD_Key this will have different values in the two cases, but same semantic,
  as it will always identify one specific version of the related entity.

## Using the Position Value timeserie

We have implemented option 1, by keeping the same POSITION_HKEY of the Position entity and 
creating a POSITION_DAILY_HDIFF that includes the Report date, that is our timeline.

Thanks to how our data is retrieved we have only one version per reprot date, therefore
we can get the full Position Value timeserie for a Position by filtering on the POSITION_HKEY.
We have a test on the VER model that validates this expectation.
