
import {deployConfig} from "./deployment/define-0-deploy_config";
import {connectContracts} from "./deployment/define-1-connect";
import {deployTools} from "./deployment/define-2-deploy-tools";
import {deployQuests} from "./deployment/define-3-deploy-quests";



deployConfig(process.env.DEPLOYER_ADDRESS)
.then(c => connectContracts(c))
.then(c => deployTools(c))
.catch(error => {
    console.error(error);
    process.exit(1);
});


