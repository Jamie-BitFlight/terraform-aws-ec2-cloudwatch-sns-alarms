'use strict';
const https = require('https');
const AWS = require('aws-sdk');
const response = require('cfn-response');
const ec2 = new AWS.EC2({apiVersion: '2016-11-15'});
function getData(cb) {
https.get('https://s3-eu-west-1.amazonaws.com/monitoring-jump-start/data/network.json', (res) => {
    if (res.statusCode === 200) {
    const chunks = [];
    res.on('data', (chunk) => chunks.push(chunk));
    res.on('end', () => {
        const body = Buffer.concat(chunks);
        const json = body.toString('utf8');
        const data = JSON.parse(json);
        cb(null, data);
    });
    } else {
        cb(new Error(`unexpected status code: ${res.statusCode}`));
    }
}).on('error', (err) => {
    cb(err);
});
}
function format(n, networkUtilizationThreshold) {
if (n === undefined) {
    return 99;
}
return Math.round(n * networkUtilizationThreshold) / 100;
}
exports.handler = (event, context) => {
console.log(`Invoke: ${JSON.stringify(event)}`);
if (event.RequestType === 'Delete') {
    response.send(event, context, response.SUCCESS, {});
} else if (event.RequestType === 'Create' || event.RequestType === 'Update') {
    getData((err, networkData) => {
    if (err) {
        console.log(`Error: ${JSON.stringify(err)}`);
        response.send(event, context, response.FAILED, {});
    } else {
        ec2.describeInstances({
        InstanceIds: [event.ResourceProperties.InstanceId]
        }, (err, instanceData) => {
        if (err) {
            console.log(`Error: ${JSON.stringify(err)}`);
            response.send(event, context, response.FAILED, {});
        } else {
            const instance = instanceData.Reservations[0].Instances[0];
            console.log(`Instance data: ${JSON.stringify(instance)}`);
            const network = networkData[instance.InstanceType];
            let networkMaximum = undefined;
            let networkBurst = undefined;
            let networkBaseline = undefined;
            if (network !== undefined) {
            if (network.baseline !== undefined && network.burst !== undefined) {
                networkBaseline = network.baseline;
                networkBurst = network.burst;
            } else if (network.baseline !== undefined) {
                networkMaximum = network.baseline;
            }
            } else {
            console.log(`No network data found for instance #${event.ResourceProperties.InstanceId} of type ${instance.InstanceType}`);
            }
            response.send(event, context, response.SUCCESS, {
            InstanceType: instance.InstanceType,
            NetworkMaximum: format(networkMaximum, event.ResourceProperties.NetworkUtilizationThreshold), // in Gbit/s
            NetworkBurst: format(networkBurst, event.ResourceProperties.NetworkUtilizationThreshold), // in Gbit/s
            NetworkBaseline: format(networkBaseline, event.ResourceProperties.NetworkUtilizationThreshold) // in Gbit/s
            }, event.ResourceProperties.InstanceId);
        }
        });
    }
    });
} else {
    cb(new Error(`unsupported RequestType: ${event.RequestType}`));
}
};