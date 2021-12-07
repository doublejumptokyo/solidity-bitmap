import hardhat from 'hardhat'
import verify from './verify.json'

const main = async () => {
    try {
        await hardhat.run("verify:verify", verify)
    } catch (e) {
        if (e.message == "Missing or invalid ApiKey") {
            console.log("Skip verifing with", e.message)
            return
        }
        if (e.message == "Contract source code already verified") {
            console.log("Skip verifing with", e.message)
            return
        }
        throw e
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
