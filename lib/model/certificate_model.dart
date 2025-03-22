class CertificateModel {
  final String name;
  final String organization;
  final String date;
  final String skills;
  final String credential;

  CertificateModel({
    required this.name,
    required this.organization,
    required this.date,
    required this.skills,
    required this.credential,
  });
}

List<CertificateModel> certificateList = [
  CertificateModel(
    name: 'IC3 GS6 Level 1',
    organization: 'Certiport - A Pearson VUE Business',
    date: 'Jul 2023',
    skills: 'Fundamental Computer',
    credential:  'Credential ID 43009703',
  ),
  CertificateModel(
    name: 'BNCC Front-End Development',
    organization: 'Bina Nusantara Computer Club',
    date: 'Issued Sep 2024',
    skills: 'FrontEnd Development',
    credential:  'Credential ID 005/LNT/III/MEMBER/BNCC/MLG/XXXV/09.2024',
  ),



];
