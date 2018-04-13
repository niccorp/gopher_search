package actions

import (
	"github.com/gobuffalo/buffalo"
	"github.com/hashicorp/vault/api"
)

func TwoFactor(c buffalo.Context) error {
	// generate a two factor token

	cfg := api.DefaultConfig()
	cfg.Address = "http://127.0.0.1:8200"

	client, _ := api.NewClient(cfg)

	secret, _ := client.Logical().Write(
		"totp/keys/my-user",
		map[string]interface{}{
			"generate":     true,
			"issuer":       "vault",
			"account_name": "test@test.com",
		})

	c.Set("uri", secret.Data["url"])
	c.Set("image", secret.Data["barcode"])
	return c.Render(200, r.HTML("mfa.html"))
}
