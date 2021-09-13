
import {deployConfig} from "./config";
import {deployWizardsMock} from "./deployment/define-0-deploy_wizards_mock";
import {deployStorage} from "./deployment/define-1-deploy_storage";
import {populateStorage} from "./deployment/define-2-populate_storage";
import {deployQuests} from "./deployment/define-3-deploy_quests";



deployConfig()
.then(c => deployWizardsMock(c))
.then(c => deployStorage(c))
.then(c => populateStorage(c))
//.then(c => deployQuests(c))
.catch(error => {
    console.error(error);
    process.exit(1);
});


