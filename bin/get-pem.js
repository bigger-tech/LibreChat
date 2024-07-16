const https = require('https');
const fs = require('fs');

const fileUrl =
    'https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem';
const outputFileName = 'global-bundle.pem';

const fileStream = fs.createWriteStream(outputFileName);

https.get(fileUrl, (response) => {
    response.pipe(fileStream);

    response.on('end', () => {
        fileStream.end();
        console.log(`File ${outputFileName} has been downloaded.`);
    });

    response.on('error', (error) => {
        console.error(`Error downloading file: ${error}`);
    });
});