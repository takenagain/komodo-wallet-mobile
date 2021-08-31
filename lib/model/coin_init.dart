// To parse this JSON data, do
//
//     final coinInit = coinInitFromJson(jsonString);

import 'dart:convert';

List<CoinInit> coinInitFromJson(String str) => List<CoinInit>.from(
    json.decode(str).map((dynamic x) => CoinInit.fromJson(x)));

String coinInitToJson(List<CoinInit> data) => json
    .encode(List<dynamic>.from(data.map<dynamic>((dynamic x) => x.toJson())));

class CoinInit {
  CoinInit({
    this.coin,
    this.name,
    this.fname,
    this.rpcport,
    this.taddr,
    this.pubtype,
    this.p2Shtype,
    this.wiftype,
    this.txfee,
    this.mm2,
    this.txversion,
    this.isPoS,
    this.overwintered,
    this.versionGroupId,
    this.consensusBranchId,
    this.requiredConfirmations,
    this.matureConfirmations,
    this.asset,
    this.segwit,
    this.dust,
    this.forceMinRelayFee,
    this.addressFormat,
    this.protocol,
    this.bech32Hrp,
  });

  factory CoinInit.fromJson(Map<String, dynamic> json) => CoinInit(
        coin: json['coin'],
        name: json['name'],
        fname: json['fname'],
        rpcport: json['rpcport'],
        taddr: json['taddr'],
        pubtype: json['pubtype'],
        p2Shtype: json['p2shtype'],
        wiftype: json['wiftype'],
        txfee: json['txfee'],
        mm2: json['mm2'],
        txversion: json['txversion'],
        isPoS: json['isPoS'],
        overwintered: json['overwintered'],
        versionGroupId: json['version_group_id'],
        requiredConfirmations: json['required_confirmations'],
        matureConfirmations: json['mature_confirmations'],
        consensusBranchId: json['consensus_branch_id'],
        asset: json['asset'],
        segwit: json['segwit'],
        addressFormat: json['address_format'],
        dust: json['dust'],
        forceMinRelayFee: json['force_min_relay_fee'],
        protocol: json['protocol'],
        bech32Hrp: json['bech32_hrp'],
      );

  String coin;
  String name;
  String fname;
  int rpcport;
  int taddr;
  int pubtype;
  int p2Shtype;
  int wiftype;
  int txfee;
  int mm2;
  int txversion;
  int isPoS;
  int overwintered;
  String versionGroupId;
  String consensusBranchId;
  int requiredConfirmations;
  int matureConfirmations;
  String asset;
  bool segwit;
  int dust;
  bool forceMinRelayFee;
  Map<String, dynamic> addressFormat;
  Map<String, dynamic> protocol;
  String bech32Hrp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'coin': coin,
        'name': name,
        'fname': fname,
        'rpcport': rpcport,
        'taddr': taddr,
        'pubtype': pubtype,
        'p2shtype': p2Shtype,
        'wiftype': wiftype,
        'txfee': txfee,
        'mm2': mm2,
        'txversion': txversion,
        'isPoS': isPoS,
        'overwintered': overwintered,
        'version_group_id': versionGroupId,
        'consensus_branch_id': consensusBranchId,
        'required_confirmations': requiredConfirmations,
        'mature_confirmations': matureConfirmations,
        'asset': asset,
        'segwit': segwit,
        if (dust != null) 'dust': dust,
        if (forceMinRelayFee != null) 'force_min_relay_fee': forceMinRelayFee,
        'address_format': addressFormat,
        'protocol': protocol,
        if (bech32Hrp != null) 'bech32_hrp': bech32Hrp,
      };
}
