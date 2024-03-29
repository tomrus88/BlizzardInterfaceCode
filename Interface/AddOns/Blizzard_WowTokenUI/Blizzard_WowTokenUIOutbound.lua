--If any of these functions call out of this file, they should be using securecall. Be very wary of using return values.
local _, tbl = ...;
local Outbound = {};
tbl.Outbound = Outbound;
tbl = nil;	--This file shouldn't be calling back into secure code.

function Outbound.RedeemFailed(result)
	securecall("RedeemFailed", result);
end

function Outbound.AuctionWowTokenUpdate()
	securecall("AuctionWowToken_UpdateMarketPrice");
end

function Outbound.RecruitAFriendTryPlayClaimRewardFanfare()
	securecall("RecruitAFriend_TryPlayClaimRewardFanfare");
end

function Outbound.RecruitAFriendTryCancelAutoClaim()
	securecall("RecruitAFriend_TryCancelAutoClaim");
end