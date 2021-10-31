const fs = require('fs');
const axios = require('axios');
const path = require('path');
const pinataSDK = require('@pinata/sdk');
const pinata = pinataSDK('9807e4444c8b18fac587', 'fcc42dccdf872e2cad73c610fd456fcba50069ef682877fb6c9d383d927e11ff');

const pinFile = () => {
    const filePath = path.join(__dirname, "videoplayback.mp4");
    const readableStreamForFile = fs.createReadStream(filePath);
    const options = {
        pinataMetadata: {
            name: "VR experience",
            keyvalues: {
                customKey: 'customValue',
                customKey2: 'customValue2'
            }
        },
        pinataOptions: {
            cidVersion: 0
        }
    };
    return pinata.pinFileToIPFS(readableStreamForFile, options).then((result) => {
        //handle results here
        return result;
    }).catch((err) => {
        //handle error here
        console.log(err);
    });   
}
const testAuthentication = () => {
    return pinata.testAuthentication().then((result) => {
        //handle successful authentication here
        return result;
    }).catch((err) => {
        //handle error here
        console.log(err);
    });
};

const pinList = () => {
    return pinata.pinList().then((result) => {
        //handle successful authentication here
        return result;
    }).catch((err) => {
        //handle error here
        console.log(err);
    });
};

module.exports = {
    testAuthentication,
    pinList,
    pinFile
}