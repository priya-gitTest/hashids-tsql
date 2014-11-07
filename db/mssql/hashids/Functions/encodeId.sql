﻿CREATE FUNCTION [hashids].[encodeId]
(
	@number int
)
RETURNS varchar(255)
WITH SCHEMABINDING
AS
BEGIN
	-- Options Data
	DECLARE
		@salt varchar(255) = 'CE6E160F053C41518582EA36CE9383D5',
		@alphabet varchar(255) = 'NxBvP0nK7QgWmejLzwdA6apRV25lkOqo8MX1ZrbyGDE3',
		@seps varchar(255) = 'CuHciSFTtIfUhs',
		@guards varchar(255) = '49JY',
		@minHashLength int = 6;

	-- Working Data
	DECLARE
		@numbersHashInt int,
		@lottery char(1),
		@buffer varchar(255),
		@last varchar(255),
		@ret varchar(255);

	SET @numbersHashInt = @number % 100;
	SET @lottery = SUBSTRING(@alphabet, (@numbersHashInt % LEN(@alphabet)) + 1, 1);
	SET @ret = @lottery;
	SET @buffer = @lottery + @salt + @alphabet;
	SET @alphabet = [hashids].[consistentShuffle](@alphabet, SUBSTRING(@buffer, 1, LEN(@alphabet)));
	SET @last = [hashids].[hash](@number, @alphabet);
	SET @ret = @ret + @last;
	----------------------------------------------------------------------------
	-- Enforce minHashLength
	----------------------------------------------------------------------------
	IF LEN(@ret) < @minHashLength BEGIN
		DECLARE
			@guardIndex int,
			@guard char(1),
			@halfLength int,
			@excess int;
		------------------------------------------------------------------------
		-- Add first 2 guard characters
		------------------------------------------------------------------------
		SET @guardIndex = (@numbersHashInt + ASCII(SUBSTRING(@ret, 1, 1))) % LEN(@guards);
		SET @guard = SUBSTRING(@guards, @guardIndex + 1, 1);
		SET @ret = @guard + @ret;
		IF LEN(@ret) < @minHashLength BEGIN
			SET @guardIndex = (@numbersHashInt + ASCII(SUBSTRING(@ret, 3, 1))) % LEN(@guards);
			SET @guard = SUBSTRING(@guards, @guardIndex + 1, 1);
			SET @ret = @ret + @guard;
		END
		------------------------------------------------------------------------
		-- Add the rest
		------------------------------------------------------------------------
		WHILE LEN(@ret) < @minHashLength BEGIN
			SET @halfLength = IsNull(@halfLength, CAST((LEN(@alphabet) / 2) as int));
			SET @alphabet = [hashids].[consistentShuffle](@alphabet, @alphabet);
			SET @ret = SUBSTRING(@alphabet, @halfLength + 1, 255) + @ret + 
					SUBSTRING(@alphabet, 1, @halfLength);
			SET @excess = LEN(@ret) - @minHashLength;
			IF @excess > 0 
				SET @ret = SUBSTRING(@ret, CAST((@excess / 2) as int) + 1, @minHashLength);
		END
	END
	RETURN @ret;
END
