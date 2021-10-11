
import {deployConfig} from "./deployment/define-0-deploy_config";
import {connectContracts} from "./deployment/define-1-connect";
import {deployTavern} from "./deployment/define-2-deploy_tavern";
import {addQuest} from "./deployment/define-3-add_quests";



deployConfig(process.env.DEPLOYER_ADDRESS)
.then(c => connectContracts(c))
.then(c => deployTavern(c))
.then(c => addQuest(c))
//.then(c => deployQuests(c))
.catch(error => {
    console.error(error);
    process.exit(1);
});


