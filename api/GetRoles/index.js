let appInsights = require('applicationinsights');
const crypto = require('crypto');


// Environment variable APPLICATIONINSIGHTS_CONNECTION_STRING or APPINSIGHTS_INSTRUMENTATIONKEY required
appInsights.setup()
let client = appInsights.defaultClient;

module.exports = async function (context, req) {
    const requestId = crypto.randomBytes(16).toString('hex'); // Not super unique, but unique enough
    try {

        let body = req.body;

        client.trackTrace({
            message: `Request started`,
            properties: { requestId: requestId, messageTemplate: 'Request started', payloadType: (typeof body) }
        });

        // Sort of horrible workaround on Azure bug. Can be removed when resolved
        if ((typeof body) === "string"){
            let patchedBody = `${body}"}`;
            let parsedOk = false;
            try {
                patchedBody = JSON.parse(patchedBody);
                parsedOk = true;
            }
            catch{}

            if (parsedOk && (typeof(patchedBody) === 'object')){
                client.trackTrace({
                    message: `Patched malformed json`,
                    properties: { requestId: requestId, messageTemplate: 'Patched malformed json' }
                });
                
                body = patchedBody;
            }
            else {
                client.trackException({
                    exception: new Error("Malformed userinfo and patching failed"),
                    properties: { requestId: requestId, payload: body, messageTemplate: 'Malformed userinfo and patching failed' }
                });
                return context.res.status(400).json({
                    "error": "malformed request"
                })
            }
        }

        const user = body || {};

        if (user.accessToken) {
            // Try to avoid logging this
            user.accessToken = "Removed";
        }

        const roles = [];

        if (!user.claims) {
            client.trackException({
                exception: new Error(`Payload has no claims`),
                properties: { requestId: requestId, payload: user, messageTemplate: 'Payload has no claims' }
            });

            return context.res.status(400).json({
                "error": "malformed request"
            })
        }
        else {
            user.claims.forEach(claim => {
                if (claim.typ === "http://schemas.microsoft.com/ws/2008/06/identity/claims/role" || claim.typ === "roles") {
                    // Mapped from role claims (aad -> enterprise application -> users&groups)
                    roles.push(claim.val);
                }
            });

            client.trackTrace({
                message: `User ${user.userId} resolved with ${roles}`,
                properties: { requestId: requestId, userOid: user.userId, userRoles: roles, messageTemplate: 'User {userOid} resolved with {userRoles}' }
            });

            return context.res.status(200).json({
                roles
            });
        }
    }
    catch (e) {
        client.trackException({
            exception: new Error(`Request failed with ${e}`),
            properties: { requestId: requestId, error: e, messageTemplate: 'Request failed with {error}' }
        });

        return context.res.status(500).json({
            "error": "Unexpected error"
        })
    }
}