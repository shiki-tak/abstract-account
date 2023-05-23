package keeper

import (
	"context"
	"strconv"

	sdk "github.com/cosmos/cosmos-sdk/types"
	authtypes "github.com/cosmos/cosmos-sdk/x/auth/types"

	"github.com/larry0x/abstract-account/x/abstractaccount/types"
)

type msgServer struct {
	k Keeper
}

func NewMsgServerImpl(k Keeper) types.MsgServer {
	return &msgServer{k}
}

func (ms msgServer) RegisterAccount(goCtx context.Context, req *types.MsgRegisterAccount) (*types.MsgRegisterAccountResponse, error) {
	ctx := sdk.UnwrapSDKContext(goCtx)

	senderAddr, err := sdk.AccAddressFromBech32(req.Sender)
	if err != nil {
		return nil, err
	}

	contractAddr, data, err := ms.k.ck.Instantiate(
		ctx,
		req.CodeID,
		senderAddr,
		senderAddr,
		req.Msg,
		types.AccountLabel(req.Sender, req.CodeID),
		req.Funds,
	)
	if err != nil {
		return nil, err
	}

	// The previous contract instantiation should have created a BaseAccount.
	// We wrap this BaseAccount in our AbstractAccount type and overwrite it.
	acc := ms.k.ak.GetAccount(ctx, contractAddr)
	baseAcc, ok := acc.(*authtypes.BaseAccount)
	if !ok {
		return nil, types.ErrNotBaseAccount
	}

	ms.k.ak.SetAccount(ctx, &types.AbstractAccount{BaseAccount: baseAcc})

	ms.k.Logger(ctx).Info(
		"abstract account registered",
		types.AttributeKeyCreator, req.Sender,
		types.AttributeKeyCodeID, req.CodeID,
		types.AttributeKeyContractAddr, contractAddr.String(),
	)

	ctx.EventManager().EmitEvent(
		sdk.NewEvent(
			types.EventTypeAccountRegistered,
			sdk.NewAttribute(types.AttributeKeyCreator, req.Sender),
			sdk.NewAttribute(types.AttributeKeyCodeID, strconv.FormatUint(req.CodeID, 10)),
			sdk.NewAttribute(types.AttributeKeyContractAddr, contractAddr.String()),
		),
	)

	return &types.MsgRegisterAccountResponse{Address: contractAddr.String(), Data: data}, nil
}