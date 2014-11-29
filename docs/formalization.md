# Model formalization

## Household agent
- Has:
	- Members -> List of People
	- Location
	- Family -> Set of households
- Calculates:
	- Resistance to move, based on:
		- Time spent living in current city
		- Distance to family members
		- Closeness to current location
		- Household size
		- Age
			- over 68 resistance increases
	- Willingness to move, based on:
		- List of attractiveness per city based on:
			- Job offers
			- Intrinsic attractiveness of city
			- Age
				- Between 16 and 23
					- for low education: short distance
					- for high education: longer distance
				- Between 23 and 30 -> Many long
				- Between 30 and 55 -> Long distance
				- Between 55 - 68 -> Long distance
- Does:
	- Move, based on:
		- If household has not moved for past x years
		- Household moves to city with highest attractiveness if it is higher than resistance
	- Progress in life stage, defined as:
		- If member with age between 16-22:
			- remove member from household and spawn new household
		- If household size is 1 and age of member is 20-25:
			- merge with another random household in same location
		- if household size is >= 2 and age of both members 23-30
			- x% chance of adding new member to household with age 0
		- If age > 75
			- x% chance of dying, remove member from household
			- if household size == 0, delete household
		- A household's life stage is based on the age of the eldest person in that household



## People (Array)
- Have: 
	- Age
	- Sex
	- job category
	- Education level

## Job offers implemented through city agents

There are a number of job categories:
- Fixed percentage required jobs, such as:
	- Agricultural
	- Service
- Growth inducing jobs, such as:
	- Manufacturing
	- ICT
	- Finance
	- Engineering

Job offers are designed for fixed percentage categories to increase the attractiveness of cities where the percentage in that category is lower than the desired percentage and to decrease the attractiveness of cities where it is higher.

The job offers for growth inducing categories are designed to increase the attractiveness of a city for people with that job category the more people of that category live in that city.


## Assumed
Moving because of need for bigger house is most often within city limits -> Out of scope of this project

# Narrative
Assume that a tick is a year in real time.

For each city:
- Calculate attractiveness of city for each job category.
	- Fixed percentage required jobs based on discrepancy between actual and desired state
	- Growth inducing jobs increases attractiveness by number of people in that category in city.


When a household becomes active it will perform the following steps:
- Increase the age of each member by one year
- Check if there are any life stage progressions
	- If child matures:
		- Remove child from current household and spawn new household with family connected to this household
		- Put child on household list to be processed later
	- If child is born:
		- Add child to household
		- Household will not move this year
	- If member dies:
		- Remove member from household
		- Household will not move this year
- Calculate resistance to move
- Calculate willingness to move:
	- For each household member:
		- calculate attractiveness of city based on city attractiveness per job category
	- Add intrinsic attractiveness of city
- Decide whether to move:
	- if highest willingness to move > resistance to move
	- AND household hasn't moved in past x years
	- Move
		