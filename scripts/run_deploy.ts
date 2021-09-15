
import {deployConfig} from "./deployment/define-0-deploy_config";
import {connectContracts} from "./deployment/define-1-connect";
import {deployTavern} from "./deployment/define-2-deploy_tavern";
import {deployQuests} from "./deployment/define-3-deploy_quests";



deployConfig()
.then(c => connectContracts(c))
.then(c => deployTavern(c))
//.then(c => populateStorage(c))
//.then(c => deployQuests(c))
.catch(error => {
    console.error(error);
    process.exit(1);
});


